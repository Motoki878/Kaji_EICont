__global__ void transent_1(double *te_result, double *slte_result,
  double *all_series, const int *positions, const double *lengths, 
  const int series_count,
 const int y_delay,
 const int duration, const double *rule)

 {                               /// TERMWISE

   int cell = blockDim.x*blockIdx.x + threadIdx.x;

   if (cell >= series_count*series_count) {
       return;
   }

  /* Constants */
  const unsigned int x_order = 1, y_order = 1,
               num_series = 3,
               num_counts = 8,
               num_x = 4,
               num_y = 2;

  /* Locals */
  int counts[8];
  unsigned long code;
  long k, l, idx, c1, c2;
  double te_final, prob_1, prob_2, prob_3;

  double *ord_iter[3]; ////
  double *ord_end[3];  ////

  int ord_times[3];
  int ord_shift[3];

  const unsigned int window = y_order + y_delay;
  const int end_time = duration - window + 1;
  int cur_time, next_time;

  /* Calculate TE */
  // double *array_ptr;
  double *i_series, *j_series; ////
  int i_size, j_size;
  int i, j;


  /* MATLAB is column major */
  i = cell/series_count;
  j = cell % series_count;

      /* Extract series */
      i_size = lengths[i];
      i_series = &all_series[positions[i]];

      j_size = lengths[j];
    j_series = &all_series[positions[j]];

      if ((i_size == 0) || (j_size == 0)) {
        te_result[(i * series_count) + j] = 0;

		//continue;
    return;
      }

      /* Order is x^(k+1), y^(l) */
      idx = 0;

      /* x^(k+1) */
      for (k = 0; k < (x_order + 1); ++k) {
        ord_iter[idx] = i_series;
        ord_end[idx] = i_series + i_size;
        ord_shift[idx] = (window - 1) - k;

        while ((int)*(ord_iter[idx]) < ord_shift[idx] + 1) {
          ++(ord_iter[idx]);
        }

        ord_times[idx] = (int)*(ord_iter[idx]) - ord_shift[idx];
        ++idx;
      }

      /* y^(l) */
      for (k = 0; k < y_order; ++k) {
        ord_iter[idx] = j_series;
        ord_end[idx] = j_series + j_size;
        ord_shift[idx] = -k;
        ord_times[idx] = (int)*(ord_iter[idx]) - ord_shift[idx];
        ++idx;
      }

      /* Count spikes */
      memset(counts, 0, sizeof(int) * num_counts);

      /* Get minimum next time bin */
      cur_time = ord_times[0];
      for (k = 1; k < num_series; ++k) {
        if (ord_times[k] < cur_time) {
          cur_time = ord_times[k];
        }
      }

      while (cur_time <= end_time) {

        code = 0;
        next_time = end_time + 1;

        /* Calculate hash code for this time bin */
        for (k = 0; k < num_series; ++k) {
          if (ord_times[k] == cur_time) {
            code |= 1 << k;

            /* Next spike for this neuron */
            ++(ord_iter[k]);

            if (ord_iter[k] == ord_end[k]) {
              ord_times[k] = end_time + 1;
            }
            else {
              ord_times[k] = (int)*(ord_iter[k]) - ord_shift[k];
            }
          }

          /* Find minimum next time bin */
          if (ord_times[k] < next_time) {
            next_time = ord_times[k];
          }
        }

        ++(counts[code]);
        cur_time = next_time;

      } /* while spikes left */

      /* Fill in zero count */
      counts[0] = end_time;
      for (k = 1; k < num_counts; ++k) {
        counts[0] -= counts[k];
      }

      /* ===================================================================== */

      /* Use counts to calculate TE */
      te_final = 0;

      /* Order is x^(k), y^(l), x(n+1) */
      for (k = 0; k < num_counts; ++k) {
        prob_1 = (double)counts[k] / (double)end_time;

        if (prob_1 == 0) {
          continue;
        }

        prob_2 = (double)counts[k] / (double)(counts[k] + counts[k ^ 1]);

        c1 = 0;
        c2 = 0;

        for (l = 0; l < num_y; ++l) {
          idx = (k & (num_x - 1)) + (l << (x_order + 1));
          c1 += counts[idx];
          c2 += (counts[idx] + counts[idx ^ 1]);
        }

        prob_3 = (double)c1 / (double)c2;

        te_final += (prob_1 * log2(prob_2 / prob_3));           
        slte_result[cell] += (prob_1 * log2(prob_2 / prob_3)) * rule[k];//SLTE

      }

      /* MATLAB is column major, but flipped for compatibility */

       te_result[cell] = te_final;


} /* transent_1 */
