function [] = timestamp_error(time, message)
   
   return;
   
   [st, i] = dbstack;
   callername = st(2).file;
   
   fp = fopen('debug_out.txt', 'a');
   fprintf(fp, '%g : %s : %s\n', time, callername, message);
   fclose(fp);
   