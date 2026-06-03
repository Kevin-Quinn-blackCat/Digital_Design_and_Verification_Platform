/*===finish===*/
event simulation_finish;
initial begin
	forever begin
		@(simulation_finish);
		$display("+------------------------------------------------------------------------------+");
		$display("|                        =====Simulation Finish=====                           |");
		$display("+------------------------------------------------------------------------------+");
		$finish;
	end
end

/*===stop===*/
event simulation_stop;
initial begin
	forever begin
		@(simulation_stop);
		$display("+------------------------------------------------------------------------------+");
		$display("|                          =====Simulation Stop=====                           |");
		$display("+------------------------------------------------------------------------------+");
		$stop;
	end
end

/*===next===*/
event simulation_next;
initial begin : SIM_NUM
	integer sim_num;
	sim_num <= 1;
	forever begin 
		@(simulation_next);
		$display("+------------------------------------------------------------------------------+");
		$display("|                          =====Simulation Next=====                           |");
		$display("|                         =====Simulation No.%0d=====                          |", sim_num);
		$display("+------------------------------------------------------------------------------+");
		sim_num <= sim_num + 1;
	end
end