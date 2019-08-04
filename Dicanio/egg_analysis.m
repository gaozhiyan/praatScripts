function []=egg_analysis()

%- analyzes all *.wav files in input_dir
%- saves corresponding data in tab-delimited text in output_dir
%- assumes there is a TextGrid for each .wav, get data for each segment
% labelled in textgrid

dbstop if error
clear all
close all
input_dir ='.\input_dir\';
output_dir ='.\output_dir\';
bw = 11;
files=dir([input_dir '*.wav']);
tg_files=dir([input_dir '*.TextGrid']);
tg_analysistier=2;
plot_on = 1;                                                            %0=no plotting, 1=plot

for i=1:length(files)

    if (exist('t1')>0), clear('t1','t2','tline','segments'); end

    fidtg = fopen([input_dir tg_files(i).name]);
    qq=1;
    while 1
        tline{qq} = fgetl(fidtg);
        if ~ischar(tline{qq}),   break,   end
        qq=qq+1;
    end
    fclose(fidtg); flg=0; cnt=0;
    for qq=1:length(tline)
        if strfind(tline{qq},'item [1]')>0, flg=1; end
        if strfind(tline{qq},'item [2]')>0, flg=2; end
        if (flg==tg_analysistier),
            if strfind(tline{qq},'text = "')>0
                x=findstr(tline{qq},'"');
                str=tline{qq}(x(end-1)+1:x(end)-1);
                if ~isempty(str)
                    cnt=cnt+1;
                    segments{cnt}=str;
                    t1{cnt} = tline{qq-2}(findstr(tline{qq-2},'=')+1:end-1);
                    t2{cnt} = tline{qq-1}(findstr(tline{qq-1},'=')+1:end-1);
                end
            end
        end
    end

    sig=[];
    [sigraw,Fs] = wavread([input_dir files(i).name]);                   %load egg signal from .wav file
    %sig = smooth(sigraw,20);                                           %smooth function not in our lab toolboxes
    nyq = Fs/2;                                                         %nyquist frequency
    lp = 1200;                                                           %lowpass frequency
    bp = [5 1200];
    [b,a]=butter(3,lp/nyq);                                             %smooth with filter
    %[b,a]=butter(3,bp/nyquist);
    sig_whole = filter(b,a,sigraw);

    for ii=1:length(segments)
        sig = sig_whole(fix(Fs*str2double(t1{ii})):fix(Fs*str2double(t2{ii})));
        sig = sig - mean(sig);
        fid = fopen([output_dir files(i).name(1:end-4) '_' segments{ii} '_' num2str(ii,'%02.0f') '.txt'],'wt');       %open output file
        dsig = diff(sig);                                                   %difference (derivative)

        % detection of egg velocity maxima
        Mx=[]; Mx2=[];                                                      %vectors for maxima of egg velocity and amp
        Mi=[]; Mi2=[];                                                      %vectors for minima of egg velocity and amp
        w=[-49 30];                                                         %window for extremum determination
        for n=-w(1)+1:length(dsig)-w(2)
            if sum(dsig(n)>=dsig([n+w(1):n-1 n+1:n+w(2)]))==w(2)-w(1)
                Mx=[Mx; n];
            end
        end

        % detection of egg velocity minima
        for n=1:length(Mx)-1
            [val,ind]   = min(dsig(Mx(n):Mx(n+1)));                         %find minimum between succesive maxima
            Mi          = [Mi; ind+Mx(n)-1];
        end

        % detection of egg maxima
        for n=1:length(Mx)-1
            [val,ind]   = max(sig((Mx(n)):(Mi(n))));                        %find egg signal maximum between successive velocity extrema
            Mx2         = [Mx2; ind+Mx(n)];
        end

        % detection of egg minima
        for n=1:length(Mi)-1
            [val,ind]   = min(sig((Mx2(n)):(Mx2(n+1))));                    %find egg signal minimum between successive velocity extrema
            Mi2         = [Mi2; ind+Mx2(n)-1];
        end

        %--ERRONEOUS PEAK REMOVAL
        %the original file had a lot of incomphrehensible thresholding to remove
        %extraneous peaks (which must be done). Below I followed several simple rules
        %1) smoothing gets rid of many bad extrema (smoothing was done above)
        %2) if a maximum/minimum amplitude is below/above some threshold (say 10%) of the maximum/minimum peak amplitude,
        %then it is erroneous.
        %3) whereever there are two consecutive minima or maxima, pick the most extreme

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        amp_thresh = .05; %peaks below max peak amp * amp_thresh are ignored
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%

        max_degg_amp = max(dsig(Mx));
        min_degg_amp = min(dsig(Mi));
        max_egg_amp = max(sig(Mx2));
        min_egg_amp = min(sig(Mi2));

        degg_max = Mx(dsig(Mx)>amp_thresh*max_degg_amp);
        degg_min = Mi(dsig(Mi)<amp_thresh*min_degg_amp);
        egg_max = Mx2(sig(Mx2)>amp_thresh*max_egg_amp);
        egg_min = Mi2(sig(Mi2)<amp_thresh*min_egg_amp);

        %make the maximum first in each pair of extrema
        degg_min = degg_min(degg_min>degg_max(1));
        egg_min = egg_min(egg_min>egg_max(1));

        %fix two consecutive degg maxima
        j=1;
        while j < length(degg_max)
            degg_min_nx = degg_min(degg_min > degg_max(j));
            if ~isempty(degg_min_nx)
                if degg_min_nx(1) > degg_max(j+1)
                    if dsig(degg_max(j)) > dsig(degg_max(j+1)), degg_max = [degg_max(1:j); degg_max(j+2:end)];
                    else if dsig(degg_max(j)) < dsig(degg_max(j+1)), degg_max = [degg_max(1:j-1); degg_max(j+1:end)]; end
                    end
                    j=j-1;
                end
            end
            j=j+1;
        end

        %fix two consecutive degg minima
        j=1;
        while j < length(degg_min)
            degg_max_nx = degg_max(degg_max > degg_min(j));
            if ~isempty(degg_max_nx)
                if degg_max_nx(1) > degg_min(j+1)
                    if dsig(degg_min(j)) < dsig(degg_min(j+1)), degg_min = [degg_min(1:j); degg_min(j+2:end)];
                    else if dsig(degg_min(j)) > dsig(degg_min(j+1)), degg_min = [degg_min(1:j-1); degg_min(j+1:end)]; end
                    end
                    j=j-1;
                end
            end
            j=j+1;
        end

        %fix two consecutive egg maxima
        j=1;
        while 1
            egg_min_nx = egg_min(egg_min > egg_max(j));
            if ~isempty(egg_min_nx)
                if egg_min_nx(1) > egg_max(j+1)
                    if sig(egg_max(j)) > sig(egg_max(j+1)), egg_max = [egg_max(1:j); egg_max(j+2:end)];
                    else if sig(egg_max(j)) < sig(egg_max(j+1)), egg_max = [egg_max(1:j-1); egg_max(j+1:end)]; end
                    end
                    j=j-1;
                end
            end
            j=j+1;
            if (j > length(egg_max)-1), break, end;
        end

        %fix two consecutive egg minima
        j=1;
        while j < length(egg_min)
            egg_max_nx = egg_max(egg_max > egg_min(j));
            if ~isempty(egg_max_nx)
                if egg_max_nx(1) > egg_min(j+1)
                    if sig(egg_min(j)) < sig(egg_min(j+1)), egg_min = [egg_min(1:j); egg_min(j+2:end)];
                    else if sig(egg_min(j)) > sig(egg_min(j+1)), egg_min = [egg_min(1:j-1); egg_min(j+1:end)]; end
                    end
                    j=j-1;
                end
            end
            j=j+1;
        end

        %--resize data vectors
        if (degg_min(end) < degg_max(end)), degg_max = degg_max(degg_max<degg_min(end)); end
        if (egg_min(end) < egg_max(end)), egg_max = egg_max(egg_max<egg_min(end)); end

        if (length(degg_min) > length(degg_max)), degg_min = degg_min(1:length(degg_max)); end
        if (length(egg_min) > length(egg_max)), egg_min = egg_min(1:length(egg_max)); end

        if (degg_max(1) < egg_max(1)),
            degg_max = degg_max(2:end);
            degg_min = degg_min(2:end);
        end
        if (degg_max(end) < egg_max(end)),
            egg_max = egg_max(2:end);
            egg_min = egg_min(2:end);
        end

        %--PLOTTING
        if (plot_on == 1)
            figure;
            subplot(3,1,1); hold on; title('EGG signal');
            plot(sig);
            %for j=1:length(Mx2), plot(Mx2(j),sig(Mx2(j)),'+r'); end   %raw extrema
            %for j=1:length(Mi2), plot(Mi2(j),sig(Mi2(j)),'+g'); end
            for jj=1:length(egg_max), plot(egg_max(jj),sig(egg_max(jj)),'+r'); end
            for jj=1:length(egg_min), plot(egg_min(jj),sig(egg_min(jj)),'+g'); end
            subplot(3,1,2); hold on; title('derivative of EGG signal');
            plot(dsig);
            %for j=1:length(Mx), plot(Mx(j),dsig(Mx(j)),'+r'); end   %raw extrema
            %for j=1:length(Mi), plot(Mi(j),dsig(Mi(j)),'+g'); end
            for jj=1:length(degg_max), plot(degg_max(jj),dsig(degg_max(jj)),'+r'); end
            for jj=1:length(degg_min), plot(degg_min(jj),dsig(degg_min(jj)),'+g'); end
        end

        %--WRITE DATA TO FILE
        %unless signals are standardized in some way, there will be
        %discrepancies in how many maxima and minima are detected, so the
        %columns are end-padded with zeros (this can be fixed if your
        %signals can be made to correspond to, for example, a single vowel)

        %%%!!!!!!!!MAXIMUM ALWAYS COMES FIRST
        fprintf(fid,'DEGGMAX\t DEGGMIN\t EGGMAX\t EGGMIN\t PER\t OQ\t CQ\n');

        max_len = max([length(degg_max) length(degg_max) length(degg_max) length(degg_max)]);   %find max column length
        degg_max = [degg_max; zeros(max_len-length(degg_max),1)];                               %pad vectors
        degg_min = [degg_min; zeros(max_len-length(degg_min),1)];
        egg_max = [egg_max; zeros(max_len-length(egg_max),1)];
        egg_min = [egg_min; zeros(max_len-length(egg_min),1)];
        degg_max = degg_max/Fs;
        degg_min = degg_min/Fs;
        egg_max = egg_max/Fs;
        egg_min = egg_min/Fs;

        %if (length(degg_max) ~= length(egg_max)), error('unequal vector lengths'); end

        %         for j=1:length(degg_max)-1
        %             dper(j) = degg_max(j+1)-degg_max(j);
        %             doq(j) = degg_min(j)-degg_max(j);
        %             dcq(j) = degg_max(j+1)-degg_min(j);
        %         end
        %         for j=1:length(egg_max)-1                             %uses egg maxima to define periods
        %             per(j) = egg_max(j+1)-egg_max(j);
        %             cq(j) = (degg_min(j+1)-degg_max(j))/per(j);
        %             oq(j) = (degg_min(j)-degg_max(j))/per(j);
        %         end
        for j=1:length(degg_max)-1                          %uses degg maxima to define periods
            per(j) = degg_max(j+1)-degg_max(j);
            cq(j) = (degg_min(j)-degg_max(j))/per(j);
            oq(j) = (degg_max(j+1)-degg_min(j))/per(j);
        end

        for j=1:length(degg_max)-1
            fprintf(fid,'%3.3f\t %3.3f\t %3.3f\t %3.3f\t %.5f\t %.3f\t %.3f\n',...
                degg_max(j),degg_min(j),egg_max(j),egg_min(j),1/per(j),oq(j),cq(j));
        end

        fclose(fid);

        if (plot_on==1)
            subplot(3,1,3);
            plot(per,'b'); hold on; plot(cq,'r'); plot(oq,'g');
            r = corrcoef(cq,oq);
            title(['OQ - CQ correlation (r) = ' num2str(r(2,1)) ]);
        end
    end
end
end

