clear all
close all

%Change these parameters for the different simulations
standard = 'ac';                    %ac or n
frame_aggregation = true;           %true or false
guard = 'short';                     %short or long

%Variable Number of Stations and Payload Size
N=0:10:500;
N(1)=1;                             %1 to 500 in steps of 10
L_data = 100:100:1500;              %100 to 1500 in steps of 100

%Frame aggregation constraints
Max_frames = 64;
Max_length = 64e3;                  %in Bytes
Max_time = 5484;                    %in us

%parameters
W = 15;
m = 6;

%Mandatory MCS for each standard
switch standard
    case 'n'
        N_DBPS = [26, 52, 78, 104, 156, 208, 234, 260];       
        DIFS = 28;                  %time (in us)
        SIFS = 10;                  %time (in us)
    case 'ac'
        N_DBPS = [26, 52, 78, 104, 156, 208, 234, 260, 312]; 
        DIFS = 34;                  %time (in us)
        SIFS = 16;                  %time (in us)
end

sigma = 9;                          %empty slot time
delta = 1;                          %propagation time
switch guard                        %guard interval
    case 'short'
        T_sym = 3.6;
    case 'long'
        T_sym = 4.0;
end

%data (in bytes)
L_header = 36;
L_ACK = 14;
L_delimiter = 4;
L_blockACK = 32;

%Throughput calculated for different MCS, Num. of Users and Payload Size
S = zeros(size(N_DBPS, 2), size(N, 2), size(L_data, 2));

%iterate for every possible number of users
for i=1:size(N, 2)
    if (N(i) == 1)
        p = 0.0;
        tau = 2/(W + 1);
    %iterate to find tau
    else
        inc = 0.000001;
        error_MAX = 0.000005;
        p= 0.0;
        tau1 = 0.0;
        tau2 = tau1 + 2*error_MAX;

        while abs(tau1 - tau2) > error_MAX
            p = p + inc;
            tau1 = 2*(1-2*p)/((1-2*p)*(W + 1) + p*W*(1-(2*p)^m));
            tau2 = 1 - (1-p)^(1/(N(1, i)-1));
        end
        tau = (tau1 + tau2)/2;          %avg value of both tau
    end
    
    %Probability of Tx
    P_tr = 1 - (1- tau)^N(1, i);
    
    %Probability of successful Tx
    P_s = N(1, i)*tau*(1- tau)^(N(1, i)-1);
    
    %Probability of collision
    P_c = P_tr - P_s;
    
    %Probability of empty slot time
    P_e = 1 - P_tr;
    
    %iterate for every MCS
    for j = 1:size(N_DBPS, 2)
        %iterate for every payload size
        for k = 1:size(L_data, 2)
            if frame_aggregation
                %calculate maximum K that fulfills requirements
                K = Max_frames;
                valid_K = false;
                
                while K > 0 && valid_K == false
                    agg_frame = (L_header+L_data(1, k))*8*K + (K - 1)*L_delimiter*8;
                    if agg_frame <= Max_length*8
                        N_sym_data = (22 + agg_frame)/N_DBPS(1, j);
                        N_ACK = (22 + (L_ACK*8))/N_DBPS(1, j);
                        
                        switch standard
                            case 'n'
                                T_data = 42 + 4*ceil(T_sym*N_sym_data/4); %in us 
                                T_ACK = 42 + 4*ceil(T_sym*N_ACK/4); %in us   
                            case 'ac'
                                T_data = 40 + 4*ceil(T_sym*N_sym_data/4); %in us 
                                T_ACK = 40 + 4*ceil(T_sym*N_ACK/4); %in us   
                        end
                        
                        if T_data <= Max_time
                            valid_K = true;
                        end
                    end
                    K = K - 1;
                end
                K = K + 1;
                    
            else
                K = 1;
                N_sym_data = (22 + ((L_header+L_data(1, k))*8))/N_DBPS(1, j);
                N_ACK = (22 + (L_ACK*8))/N_DBPS(1, j);
                
                switch standard
                    case 'n'
                        T_data = 42 + 4*ceil(T_sym*N_sym_data/4); %in us 
                        T_ACK = 42 + 4*ceil(T_sym*N_ACK/4); %in us   
                    case 'ac'
                        T_data = 40 + 4*ceil(T_sym*N_sym_data/4); %in us 
                        T_ACK = 40 + 4*ceil(T_sym*N_ACK/4); %in us   
                end
            end

            %Time of a successful Tx (in us)
            T_s = DIFS + T_data + 2*delta + SIFS + T_ACK;

            %Collision duration (in us)
            T_c = DIFS + T_data + delta;

            %Average slot duration
            E_s = P_e*sigma + P_s*T_s + P_c*T_c;

            %System throughput (in Mbps) S(MCS, #users, payload)
            S(j, i, k) = P_s*L_data(1, k)*K*8/E_s;
        end
    end
end

%plot throughput vs number of users for fix payload (1500B)
plot(N, S(:,:,end));
xlabel('Number of users');
ylabel('Throughput (Mbps)');
legend('26Mb/s','52Mb/s','78Mb/s','104Mb/s','156Mb/s','208Mb/s','234Mb/s','260Mb/s');
title('Throughput vs User load');
switch standard
    case 'n'
        switch guard
            case 'short'
                legend('7.2 Mb/s', '14.4 Mb/s', '21.7 Mb/s', '28.9 Mb/s', '43.3 Mb/s', '57.8 Mb/s', '65 Mb/s', '72.2 Mb/s');
            case 'long'
                legend('6.5 Mb/s', '13 Mb/s', '19.5 Mb/s', '26 Mb/s', '39 Mb/s', '52 Mb/s', '58.5 Mb/s', '65 Mb/s');
        end
    case 'ac'
        switch guard
            case 'short'
                legend('7.2 Mb/s', '14.4 Mb/s', '21.7 Mb/s', '28.9 Mb/s', '43.3 Mb/s', '57.8 Mb/s', '65 Mb/s', '72.2 Mb/s', '86.7 Mb/s');
            case 'long'
                legend('6.5 Mb/s', '13 Mb/s', '19.5 Mb/s', '26 Mb/s', '39 Mb/s', '52 Mb/s', '58.5 Mb/s', '65 Mb/s', '78 Mb/s');
        end
end

figure();
%plot throughput vs payload size for ideal case (1 user)
plot(L_data, squeeze(S(:,1,:)));
xlim([100 1500]);
xlabel('Payload size (Bytes)');
ylabel('Throughput (Mbps)');
%6.5, 13, 19.5, 26, 39, 52, 58.5, 65 and 78Mbps
switch standard
    case 'n'
        switch guard
            case 'short'
                legend('7.2 Mb/s', '14.4 Mb/s', '21.7 Mb/s', '28.9 Mb/s', '43.3 Mb/s', '57.8 Mb/s', '65 Mb/s', '72.2 Mb/s', 'Location', 'NorthWest');
            case 'long'
                legend('6.5 Mb/s', '13 Mb/s', '19.5 Mb/s', '26 Mb/s', '39 Mb/s', '52 Mb/s', '58.5 Mb/s', '65 Mb/s', 'Location', 'NorthWest');
        end
    case 'ac'
        switch guard
            case 'short'
                legend('7.2 Mb/s', '14.4 Mb/s', '21.7 Mb/s', '28.9 Mb/s', '43.3 Mb/s', '57.8 Mb/s', '65 Mb/s', '72.2 Mb/s', '86.7 Mb/s', 'Location', 'NorthWest');
            case 'long'
                legend('6.5 Mb/s', '13 Mb/s', '19.5 Mb/s', '26 Mb/s', '39 Mb/s', '52 Mb/s', '58.5 Mb/s', '65 Mb/s', '78 Mb/s', 'Location', 'NorthWest');
        end
end
title('Throughput vs Payload size');
