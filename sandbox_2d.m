% Sandbox (13/03/14) Andy Martin
% 2d sand pile code.
% the autonoma is as follows:
% (1) Consider N (2->N_sites+1, 2->N_sites+1) sites on which the sand can sit
% (2) If the sand is on site 1 or N_site+2 then it is deemed to have
% fallen off
% (3) Randomly choose a site and place a sand grain on it
% (4) If N(i,j) -N(i pm 1, j pm 1) > z_str then allow particles to "tumble" to
% nearest neighbours: use the following rules (i) the number of grains that
% can tumble is a random number between 1 and N(i,j)-N(i pm 1, j pm 1). 
% (5) Consider if tumbling can occur for sites on which particles have
% moved to using conditions set in (4). Repeat until tumbling has stopped
% (6) Repeat from (3) until bored.

clear all;

N_sites=100; % length of side of pile
z_str=5; % critical gradient
N_drops=N_sites*N_sites*100; % total number of sand droped onto pile

N_mat=zeros(N_sites+2,N_sites+2); % initialize number of sand particles on each site to 0


for i=1:N_drops % loop of drops of sand
    domain=zeros(N_sites+2,N_sites+2); % initialize the size of "tumbling" domain to zero for each drop
    drop(i)=0; % initialize the number of particles that have fallen of pile to zero
    i/N_drops % time keeping
    
    % choose a random site
    rx=randi(N_sites)+1;
    ry=randi(N_sites)+1;
    domain(rx,ry)=1; % update domain to include the site on which the sand has been droped
    N_mat(rx,ry)=N_mat(rx,ry)+1; % update the number of particles on that site
    tumble=0; % define a quantity that quantifies if tumbling (i.e. particles have moved) has occured 
    
    % local gradients
    dum1=N_mat(rx,ry)-N_mat(rx+1,ry);
    dum2=N_mat(rx,ry)-N_mat(rx-1,ry);
    dum3=N_mat(rx,ry)-N_mat(rx,ry+1);
    dum4=N_mat(rx,ry)-N_mat(rx,ry-1);
    %counts the number of sites which have changed the number of particles (excluding site on which the random particle has been droped) 
    %due to tumbling
    t=0;
    if ((dum1 >= z_str) || (dum2 >= z_str) || (dum3 >= z_str) || (dum4 >= z_str)) % Has the criteria for tumbling been met? If so tumble.
        s1=0; % initialize: no tumbling has occured between rx,ry and rx+1, ry
        s2=0; % initialize: no tumbling has occured between rx,ry and rx-1, ry
        s3=0; % initialize: no tumbling has occured between rx,ry and rx, ry+1
        s4=0; % initialize: no tumbling has occured between rx,ry and rx, ry-1
        for k=1:8 % loop over random possibilities of tumbling
            slide=randi(4); % choose to consider tumbling between rx and rx+1,ry (slide =1)....
            if ((slide==1) && s1==0) % if consider sliding betwen rx,ry and rx+1,ry (slide =1) then check have not already done this (note loop)
                s1=1; % mark that you have now considered sliding between rx,ry and rx+1,ry
                if (N_mat(rx,ry) > N_mat(rx+1,ry)) % If more particles of site rx,ry than rx+1,ry allow to tumble
                    n_slide=randi(N_mat(rx,ry)-N_mat(rx+1,ry)); % choose a random number of particles to tumble  
                    N_mat(rx+1,ry)=N_mat(rx+1,ry)+n_slide; % add the number of particles that have tumbled to the site rx+1,ry
                    N_mat(rx,ry)=N_mat(rx,ry)-n_slide;  % subtract the number of particles that have tumbled from site rx
                    % note that tumbling has occured and mark the site that
                    % has had extra particles added to it
                    tumble=1; 
                    t=t+1;
                    next(t,1)=rx+1;
                    next(t,2)=ry; 
                    
                    if (domain(rx+1,ry)==0) % update the domain to include the site on which particles have moved to
                        domain(rx+1,ry)=domain(rx+1,ry)+1;
                    end
                end
            end
            
            % same as above but for sliding between rx,ry and rx-1,ry
            if ((slide==2) && s2==0)
                s2=1;
                if (N_mat(rx,ry) > N_mat(rx-1,ry))
                    n_slide=randi(N_mat(rx,ry)-N_mat(rx-1,ry));
                    N_mat(rx-1,ry)=N_mat(rx-1,ry)+n_slide;
                    N_mat(rx,ry)=N_mat(rx,ry)-n_slide;
                    tumble=1;
                    t=t+1;
                    next(t,1)=rx-1;
                    next(t,2)=ry;
                    if (domain(rx-1,ry)==0)
                        domain(rx-1,ry)=domain(rx-1,ry)+1;
                    end
                end
            end
            
            % same as above but for sliding between rx,ry and rx,ry+1
            if ((slide==3) && s3==0)
                s3=1;
                if (N_mat(rx,ry) > N_mat(rx,ry+1))
                    n_slide=randi(N_mat(rx,ry)-N_mat(rx,ry+1));
                    N_mat(rx,ry+1)=N_mat(rx,ry+1)+n_slide;
                    N_mat(rx,ry)=N_mat(rx,ry)-n_slide;
                    tumble=1;
                    t=t+1;
                    next(t,1)=rx;
                    next(t,2)=ry+1;
                    if (domain(rx,ry+1)==0)
                        domain(rx,ry+1)=domain(rx,ry+1)+1;
                    end
                end
            end
            
            % same as above but for sliding between rx,ry and rx,ry-1
            if ((slide==4) && s4==0)
                s4=1;
                if (N_mat(rx,ry) > N_mat(rx,ry-1))
                    n_slide=randi(N_mat(rx,ry)-N_mat(rx,ry-1));
                    N_mat(rx,ry-1)=N_mat(rx,ry-1)+n_slide;
                    N_mat(rx,ry)=N_mat(rx,ry)-n_slide;
                    tumble=1;
                    t=t+1;
                    next(t,1)=rx;
                    next(t,2)=ry-1;
                    if (domain(rx,ry-1)==0)
                        domain(rx,ry-1)=domain(rx,ry-1)+1;
                    end
                end
            end
        end
    end
    
    % Count the number of droped particles due to tumble
    drop(i)=drop(i)+sum(N_mat(:,1));
    N_mat(:,1)=0;
    drop(i)=drop(i)+sum(N_mat(:,N_sites+2));
    N_mat(:,N_sites+2)=0;
    drop(i)=drop(i)+sum(N_mat(1,:));
    N_mat(1,:)=0;
    drop(i)=drop(i)+sum(N_mat(N_sites+2,:));
    N_mat(N_sites+2,:)=0;
    
    
    while tumble==1 % if tumble ==1 then need to check sites which particles have tumbled to.
        tumble=0; % reset tumble to 0
        next_s=next; % next_s is the contains sites particles have previously tumbled to in last iteration.
        t_s=t;
        t=0;
        clear next % going to create a new next for this iteration of tumbling
        for j=1:t_s % run over all the sites which increased there number of particles in the last iteration
            rx=next_s(j,1); % find particlar rx
            ry=next_s(j,2); % find particlar ry
            if (rx==1 || ry==1 || rx==N_sites+2 || ry==N_sites+2) % if rx or ry on end of pile can ignore (no tumbling they fall)
                dum1=0;
                dum2=0;
                dum3=0;
                dum4=0;
            else 
                dum1=N_mat(rx,ry)-N_mat(rx+1,ry); % if not at end of pile determine the local gradient
                dum2=N_mat(rx,ry)-N_mat(rx-1,ry);
                dum3=N_mat(rx,ry)-N_mat(rx,ry+1);
                dum4=N_mat(rx,ry)-N_mat(rx,ry-1);
            end
            t_count=0;
            
            % as above for propogating tumble
            if ((dum1 >= z_str) || (dum2 >= z_str) || (dum3 >= z_str) || (dum4 >= z_str))
                s1=0;
                s2=0;
                s3=0;
                s4=0;
                for k=1:8
                    slide=randi(4);
                    if ((slide==1) && s1==0)
                        s1=1;
                        if (N_mat(rx,ry) > N_mat(rx+1,ry))
                            n_slide=randi(N_mat(rx,ry)-N_mat(rx+1,ry));
                            N_mat(rx+1,ry)=N_mat(rx+1,ry)+n_slide;
                            N_mat(rx,ry)=N_mat(rx,ry)-n_slide;
                            tumble=1;
                            t=t+1;
                            next(t,1)=rx+1;
                            next(t,2)=ry;
                            if (domain(rx+1,ry)==0)
                                domain(rx+1,ry)=domain(rx+1,ry)+1;
                            end
                        end
                    end
                    if ((slide==2) && s2==0)
                        s2=1;
                        if (N_mat(rx,ry) > N_mat(rx-1,ry))
                            n_slide=randi(N_mat(rx,ry)-N_mat(rx-1,ry));
                            N_mat(rx-1,ry)=N_mat(rx-1,ry)+n_slide;
                            N_mat(rx,ry)=N_mat(rx,ry)-n_slide;
                            tumble=1;
                            t=t+1;
                            next(t,1)=rx-1;
                            next(t,2)=ry;
                            if (domain(rx-1,ry)==0)
                                domain(rx-1,ry)=domain(rx-1,ry)+1;
                            end
                        end
                    end
                    if ((slide==3) && s3==0)
                        s3=1;
                        if (N_mat(rx,ry) > N_mat(rx,ry+1))
                            n_slide=randi(N_mat(rx,ry)-N_mat(rx,ry+1));
                            N_mat(rx,ry+1)=N_mat(rx,ry+1)+n_slide;
                            N_mat(rx,ry)=N_mat(rx,ry)-n_slide;
                            tumble=1;
                            t=t+1;
                            next(t,1)=rx;
                            next(t,2)=ry+1;
                            if (domain(rx,ry+1)==0)
                                domain(rx,ry+1)=domain(rx,ry+1)+1;
                            end
                        end
                    end
                    if ((slide==4) && s4==0)
                        s4=1;
                        if (N_mat(rx,ry) > N_mat(rx,ry-1))
                            n_slide=randi(N_mat(rx,ry)-N_mat(rx,ry-1));
                            N_mat(rx,ry-1)=N_mat(rx,ry-1)+n_slide;
                            N_mat(rx,ry)=N_mat(rx,ry)-n_slide;
                            tumble=1;
                            t=t+1;
                            next(t,1)=rx;
                            next(t,2)=ry-1;
                            if (domain(rx,ry-1)==0)
                                domain(rx,ry-1)=domain(rx,ry-1)+1;
                            end
                        end
                    end
                end
            end
            % Calculate number droped due to tumble
            drop(i)=drop(i)+sum(N_mat(:,1));
            N_mat(:,1)=0;
            drop(i)=drop(i)+sum(N_mat(:,N_sites+2));
            N_mat(:,N_sites+2)=0;
            drop(i)=drop(i)+sum(N_mat(1,:));
            N_mat(1,:)=0;
            drop(i)=drop(i)+sum(N_mat(N_sites+2,:));
            N_mat(N_sites+2,:)=0;
                    
        end;
    end;
    % For that drop of sand calculate the size of the domain
    domain(:,1)=0;
    domain(1,:)=0;
    domain(N_sites+2,:)=0;
    domain(:,N_sites+2)=0;
    domain_size(i)=sum(sum(domain));
end;

% Calculate pdfs
pdf_drop(max(drop)+1)=0;
pdf_size(max(domain_size))=0;
for i=1:max(drop)+1
    S_d(i)=i-1;
end
for i=1:max(domain_size)
    S_s(i)=i;
end

for i=1:N_drops
    pdf_drop(drop(i)+1)=pdf_drop(drop(i)+1)+1;
    pdf_size(domain_size(i))=pdf_size(domain_size(i))+1;
end
pdf_drop=pdf_drop/N_drops;
pdf_size=pdf_size/N_drops;

% Calculate moments
m1_drop=sum(S_d.*pdf_drop);
m2_drop=sum(S_d.*S_d.*pdf_drop);
m3_drop=sum(S_d.*S_d.*S_d.*pdf_drop);
m4_drop=sum(S_d.*S_d.*S_d.*S_d.*pdf_drop);

m1_size=sum(S_s.*pdf_size);
m2_size=sum(S_s.*S_s.*pdf_size);
m3_size=sum(S_s.*S_s.*S_s.*pdf_size);
m4_size=sum(S_s.*S_s.*S_s.*S_s.*pdf_size);



        
    