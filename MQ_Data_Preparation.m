close all;
clear all;
clc;
warning off;
tStart = tic;
diary 'diary.txt';
fprintf('%s\n',['Date: ' datestr(now, 'dd/mmmm/yyyy - HH:MM:SS')]);
LocalCatalog = readtable('Shallow_Catalog.txt','HeaderLines',1,'TextType','char','Format','%s%s%s%s%s%s%s');
FlatModeOperationTerm = readtable('Flat_Mode_Operation_Term.txt','HeaderLines',1,'TextType','char','Format','%s%s%s%s%s%s%s');
mkdir 'Darts_Data_Preparation';
cd 'Darts_Data_Preparation';
root = pwd;
for EventNumber=1:size(LocalCatalog,1)
    EventFolder = char(LocalCatalog{EventNumber,1});
    mkdir(EventFolder);
    cd(EventFolder);	
    mkdir 'LP';
    cd 'LP';
    mkdir '01-Darts';
	mkdir '02-Extracted';
	cd '02-Extracted';
	mkdir 'Plot';
    cd ..
    mkdir '03-PreProcessed';
	cd '03-PreProcessed';
	mkdir 'Plot';
    cd ..
    mkdir '04-Deconvolved';
	cd '04-Deconvolved';
	mkdir 'Acc';
	mkdir 'Vel';
	mkdir 'Des';
	mkdir 'Plot';
	cd 'Plot';
	mkdir 'Acc';
	mkdir 'Vel';
	mkdir 'Des';
	cd([root '\' EventFolder]);
    mkdir 'SP';
    cd 'SP';
    mkdir '01-Darts';
	mkdir '02-Extracted';
	cd '02-Extracted';
	mkdir 'Plot';
    cd ..
    mkdir '03-PreProcessed';
	cd '03-PreProcessed';
	mkdir 'Plot';
    cd ..
    mkdir '04-Deconvolved';
	cd '04-Deconvolved';
	mkdir 'Acc';
	mkdir 'Vel';
	mkdir 'Dis';
	mkdir 'Plot';
	cd 'Plot';
	mkdir 'Acc';
	mkdir 'Vel';
	mkdir 'Dis';
	cd(root);
end
RMS = [];
for EventNumber=1:size(LocalCatalog,1)
    EventFolder = char(LocalCatalog{EventNumber,1});
    cd(EventFolder);
	RecordType = 'lp';
    cd 'LP';
    cd '01-Darts';
	RecordStartYear = str2double(LocalCatalog{EventNumber,2});
	RecordStartDoy = str2double(LocalCatalog{EventNumber,3});
	RecordStartTime = char(LocalCatalog{EventNumber,6});
	RecordEndTime = char(LocalCatalog{EventNumber,7});
    count = 0;
    err_count = 0;
    while count == err_count
        try
            %DartsDownload(RecordType,RecordStartYear,RecordStartDoy,RecordStartTime,RecordEndTime);
        catch
            if err_count<=100
                err_count = err_count + 1;
            else
                break
            end
        end
        count = count + 1;
    end
	ddir = dir(fullfile(pwd,'lp*.csv'));
	A = {};
	C = [];
	for ii = 1:length(ddir)
		filename = ddir(ii).name;
		if (ii == 1)
			ttStartHour = str2double(filename(12:13));
		end
		[A,C] = RecordExtraction(A,ii,RecordType,filename,ttStartHour);
    end
	cd ..
	cd '02-Extracted';
	SaveExtracted(EventFolder,RecordType,RecordStartYear,RecordStartDoy,A,C);
    ddir = dir(fullfile(pwd,'02*.txt'));
    A = {};
	for ii = 1:length(ddir)
		filename = ddir(ii).name;
        try
		    A = PreProcessing(ii,filename,RecordType,A,LocalCatalog);
        catch
            % Nothing to do
        end
	end
	cd ..
	cd '03-PreProcessed';
	for ii = 1:length(ddir)
		filename = ddir(ii).name;
        try
            SavePreProcessed(ii,filename,RecordType,A);
        catch
            % Nothing to do
        end
    end
    ddir = dir(fullfile(pwd,'03*.txt'));
    A = {};
	for ii = 1:length(ddir)
		filename = ddir(ii).name;
        try
		    [A,RMS] = Deconvolution(ii,filename,A,RMS,LocalCatalog,FlatModeOperationTerm);
        catch
            % Nothing to do
        end
    end
    cd ..
	cd '04-Deconvolved';
	for ii = 1:length(ddir)
		filename = ddir(ii).name;
        try
            SaveDeconvolved(ii,filename,A);
        catch
            % Nothing to do
        end
    end
	cd([root '\' EventFolder]);
	RecordType = 'sp';
    cd 'SP';
    cd '01-Darts';
	RecordStartYear = str2double(LocalCatalog{EventNumber,2});
	RecordStartDoy = str2double(LocalCatalog{EventNumber,3});
	RecordStartTime = char(LocalCatalog{EventNumber,6});
	RecordEndTime = char(LocalCatalog{EventNumber,7});
 	count = 0;
    err_count = 0;
    while count == err_count
        try
            %DartsDownload(RecordType,RecordStartYear,RecordStartDoy,RecordStartTime,RecordEndTime);
        catch
            if err_count<=100
                err_count = err_count + 1;
            else
                break
            end
        end
        count = count + 1;
    end
    ddir = dir(fullfile(pwd,'sp*.csv'));
	A = {};
	c = [];
	for ii = 1:length(ddir)
		filename = ddir(ii).name;
		if (ii == 1)
			ttStartHour = str2double(filename(12:13));
		end
		[A,C] = RecordExtraction(A,ii,RecordType,filename,ttStartHour);
	end
	cd ..
	cd '02-Extracted';
	SaveExtracted(EventFolder,RecordType,RecordStartYear,RecordStartDoy,A,C);
    ddir = dir(fullfile(pwd,'02*.txt'));
    A = {};
	for ii = 1:length(ddir)
		filename = ddir(ii).name;
        try
		    A = PreProcessing(ii,filename,RecordType,A,LocalCatalog);
        catch
            % Nothing to do
        end
	end
	cd ..
	cd '03-PreProcessed';
	for ii = 1:length(ddir)
		filename = ddir(ii).name;
        try
            SavePreProcessed(ii,filename,RecordType,A);
        catch
            % Nothing to do
        end
	end
    ddir = dir(fullfile(pwd,'03*.txt'));
	A = {};
	for ii = 1:length(ddir)
		filename = ddir(ii).name;
        try
		    [A,RMS] = Deconvolution(ii,filename,A,RMS,LocalCatalog,FlatModeOperationTerm);
        catch
            % Nothing to do
        end
	end
    cd ..
	cd '04-Deconvolved';
	for ii = 1:length(ddir)
		filename = ddir(ii).name;
        try
            SaveDeconvolved(ii,filename,A);
        catch
            % Nothing to do
        end
    end
    cd(root);
end
cd ..
tEnd = toc(tStart);
fprintf('%d minutes and %d seconds\n', floor(tEnd/60), ceil(rem(tEnd,60)));
diary off;

 function DartsDownload(RecordType,RecordStartYear,RecordStartDoy,RecordStartTime,RecordEndTime)
    RecordStartHour = str2double(RecordStartTime(1:2));
    RecordEndHour = str2double(RecordEndTime(1:2));
	if (RecordEndHour == 99)
		RecordEndHour = RecordStartHour +2;
	end
    if (RecordEndHour < RecordStartHour)
        RecordEndHour = RecordEndHour + 24;
    end
    RecordEndMin = str2double(RecordEndTime(3:4));
	if (RecordEndMin == 99)
		RecordEndMin = 00;
	end
	if (RecordEndMin > 00)
		RecordEndHour = RecordEndHour + 1;
	end
	RecordStartDateTime = datetime(RecordStartYear,01,RecordStartDoy,RecordStartHour,00,00);
	for ii = 0:(RecordEndHour-RecordStartHour-1)
		url = ['https://darts.jaxa.jp/planet/seismology/apollo/dump/dump/' RecordType '/START_TIME/' datestr(RecordStartDateTime + hours(ii),'yyyy-mm-dd') 'T' datestr(RecordStartDateTime + hours(ii),'HH')  ':00:00/STOP_TIME/' datestr(RecordStartDateTime + hours(ii + 1),'yyyy-mm-dd') 'T' datestr(RecordStartDateTime + hours(ii + 1),'HH') ':00:00'];
		filename = [RecordType '_' datestr(RecordStartDateTime + hours(ii),'yyyymmddHH') '0000_' datestr(RecordStartDateTime + hours(ii + 1),'yyyymmddHH') '0000.csv'];
		options = weboptions('Timeout',30);
        websave(filename,url,options);
	end
 end
 
 function [A,C] = RecordExtraction(A,ii,RecordType,filename,ttStartHour)
	table = readtable(filename,'HeaderLines',1,'TextType','char','DatetimeType','text');
	station = table2array(table(:,2));
	tt = table2cell(table(:,5));
    if strcmp(RecordType,'lp')
	    lpx = table2array(table(:,6));
	    lpy = table2array(table(:,7));
	    lpz = table2array(table(:,8));
    elseif strcmp(RecordType,'sp')
	    spz = table2array(table(:,6));
    end	
	N = length(tt);
	for jj = 1:N
		ttHour(jj,1) = str2double(tt{jj,1}(1,12:13))-ttStartHour;
		if (ttHour(jj)<0)
			ttHour(jj) = ttHour(jj) + 24;
		end
		ttMin(jj,1) = str2double(tt{jj,1}(1,15:16));
		ttSec(jj,1) = str2double(tt{jj,1}(1,18:end));
	end
	tt = 3600*ttHour + 60*ttMin + ttSec;
	[C,ia] = unique(station);
	for jj = 1:length(C)
        if (jj == length(C))
		    v(jj,:) = [ia(jj); N];
        else
			v(jj,:) = [ia(jj); ia(jj+1)-1];
        end
	end
	for jj = 1:length(C)
		vjj = [v(jj,1):v(jj,2)];
        if strcmp(RecordType,'lp')
	        A{ii,jj} = [tt(vjj,1) lpx(vjj,1) lpy(vjj,1) lpz(vjj,1)];
        elseif strcmp(RecordType, 'sp')
	        A{ii,jj} = [tt(vjj,1) spz(vjj,1)];
        end
	end
end

function SaveExtracted(EventFolder,RecordType,RecordStartYear,RecordStartDoy,A,C)
    if strcmp(RecordType,'lp')
		component = char('LPX','LPY','LPZ');
		componentCount = 3;
    elseif strcmp(RecordType,'sp')
	    component = char('SPZ');
		componentCount = 1;
    end		
	for jj = 1:size(A,2)
		stationStr = ['ST' num2str(C(jj))];
		for kk = 1:componentCount
			if (C(jj) == 12) && (strcmp(RecordType,'sp')) && (kk == 1) && (datetime(RecordStartYear,01,RecordStartDoy) >= datetime(1969,11,19))
				% Nothing to do
			elseif (C(jj) == 14) && (strcmp(RecordType,'lp')) && (kk == 3) && (datetime(RecordStartYear,01,RecordStartDoy) >= datetime(1972,03,20))
				% Nothing to do
			else
				B = [];
				for ii = 1:size(A,1)
					B = [B; A{ii,jj}(:,[1,kk+1])];
				end
				RegisterName = strcat(EventFolder,'-',stationStr,'-',component(kk,1:3));
				fid = fopen(['02-' RegisterName '.txt'], 'wt');
				fprintf(fid,'%s\n',['% Date: ' datestr(now, 'dd/mmmm/yyyy-HH:MM:SS')]);
				fprintf(fid,'%s\n','% Extracted Apollo seismogram record');
				fprintf(fid,'%s\n',['% File: 02-' RegisterName '.txt']);
				fprintf(fid,'%s\n',['% Event: ' RegisterName(1:3)]);
				fprintf(fid,'%s\n',['% Station: ' RegisterName(7:8)]);
				fprintf(fid,'%s\n',['% Record Type:' RegisterName(10:11)]);
				fprintf(fid,'%s\n',['% Component: ' RegisterName(12)]);
				fprintf(fid,'%s\n','% First Column: Time (s)');
				fprintf(fid,'%s\n','% Second Column: Amplitud (DU)');
				fprintf(fid,'%s\n','% Matlab Loading Method:');
				fprintf(fid,'%s\n',['% fileID = fopen(''02-' RegisterName '.txt'');']);
				fprintf(fid,'%s\n','% Data = cell2mat(textscan(fileID,''%f %f'',''headerlines'',15));');
				fprintf(fid,'%s\n','% fclose(fileID);');
				fprintf(fid,'\n');
				fprintf(fid,'\n');
				for ll = 1:size(B,1)
					fprintf(fid,'%6.6f\t%.4g',B(ll,:));
					fprintf(fid,'\n');
				end 
				fclose(fid);
				hfig = figure('Visible','off');
				plot(B(:,1),B(:,2));
				grid on;
				xmax = max(B(:,1));
				ymax = 1.1*1024;
				axis([0 xmax 0 ymax]);
				titleStr = 'Darts Seismogram';
				title({titleStr,RegisterName},'FontWeight','bold');
				ylabel('Amplitude [DU]','FontWeight','bold');
				xlabel('Time [s]','FontWeight','bold');
				saveas(hfig,['Plot\02-' RegisterName],'pdf');
				close (gcf);
			end
		end
	end
end

function A = PreProcessing(ii,filename,RecordType,A,LocalCatalog)
    ShallowNumber = str2double(filename(5:6));
    StartTime = char(LocalCatalog{ShallowNumber,6});
    EndTime = char(LocalCatalog{ShallowNumber,7});
    StartHour = str2double(StartTime(1:2));
    EndHour = str2double(EndTime(1:2));
    if (EndHour<StartHour)
        EndHour = EndHour + 24;
    end
    StartMin = str2double(StartTime(3:4));
    EndMin = str2double(EndTime(3:4));
    TStart = 60*StartMin;
    TEnd = 3600*(EndHour-StartHour) + 60*EndMin;
	fileID = fopen(filename);
	eventData = cell2mat(textscan(fileID,'%f %f','headerlines',15));
    fclose(fileID);
    tt = eventData(:,1);
    DU = eventData(:,2);
    Z = find(diff(tt)<=0) + 1;
    tt(Z) = [];
    DU(Z) = [];
	LowLimit = 0;
	HighLimit = 0;
	flag = 0;
    for jj = 1:length(tt)
        if (tt(jj) < TStart)
            LowLimit = jj;
        elseif (tt(jj) >= TEnd) && (flag==0)
            HighLimit = jj;
            flag = 1;
        end
    end
    if (LowLimit ~= 0) && (HighLimit ~= 0)
        tt([1:LowLimit,HighLimit:end]) = [];
        DU([1:LowLimit,HighLimit:end]) = [];
    elseif (LowLimit ~= 0) && (HighLimit == 0)
        tt(1:LowLimit) = [];
        DU(1:LowLimit) = [];
    elseif (LowLimit == 0) && (HighLimit ~= 0)
        tt(HighLimit:end) = [];
        DU(HighLimit:end) = [];
    end
	tt = tt - tt(1);
    if  strcmp(RecordType,'lp')
        fs = 1/0.15094;
    elseif  strcmp(RecordType,'sp')
        fs = 1/0.018868;
    end
    dt = 1/fs;
    N = fix(tt(end)/dt);
	tt2 = [0:N-1].'*dt;
	DU2 = interp1(tt,DU,tt2);
    tt = tt2;
    DU = DU2;
    if (mod(length(tt),2)==1)
        tt(end) = [];
        DU(end) = [];
    end
    DU = detrend(hampel(detrend(DU),1000,3.5));
    A{ii,1} = [tt DU];
end

function SavePreProcessed(ii,filename,RecordType,A)
    B = A{ii,1};
    fid = fopen(['03' filename(3:end)], 'wt');
	fprintf(fid,'%s\n',['% Date: ' datestr(now, 'dd/mmmm/yyyy-HH:MM:SS')]);
	fprintf(fid,'%s\n','% Processed Apollo seismogram record');
	fprintf(fid,'%s\n',['% File: 03' filename(3:end)]);
	fprintf(fid,'%s\n',['% Event: ' filename(4:6)]);
	fprintf(fid,'%s\n',['% Station: ' filename(10:11)]);
	fprintf(fid,'%s\n',['% Record Type:' filename(13:14)]);
	fprintf(fid,'%s\n',['% Component: ' filename(15)]);
	fprintf(fid,'%s\n','% First Column: Time (s)');
	fprintf(fid,'%s\n','% Second Column: Amplitud (DU)');
	fprintf(fid,'%s\n','% Matlab Loading Method:');
	fprintf(fid,'%s\n',['% fileID = fopen(''03' filename(3:end) ''');']);
	fprintf(fid,'%s\n','% Data = cell2mat(textscan(fileID,''%f %f'',''headerlines'',15));');
	fprintf(fid,'%s\n','% fclose(fileID);');
	fprintf(fid,'\n');
	fprintf(fid,'\n');
    for ll = 1:size(B,1)
        fprintf(fid,'%6.6f\t%.6f',B(ll,:));
        fprintf(fid,'\n');
    end 
    fclose(fid);
    hfig = figure('Visible','off');
    subplot(2,1,1);
    plot(B(:,1),B(:,2));
    grid on;
    xmax = max(B(:,1));
    ymax = 1.1*max(abs(B(:,2)));
    axis([0 xmax -ymax ymax]);
    title('Seismogram');
    ylabel('Amplitude [DU]','FontWeight','bold');
    xlabel('Time [s]','FontWeight','bold');
    subplot(2,1,2);
    nfft = 2^(nextpow2(size(B,1))-7);
	noverlap = nfft/2;
	window = nfft;
    if  strcmp(RecordType,'lp')
        fs = 1/0.15094;
    elseif  strcmp(RecordType,'sp')
        fs = 1/0.018868;
    end
	[psd,ff] = pwelch(B(:,2),nfft,noverlap,window,fs);
	semilogx(ff,db(psd));
    grid on;
	axis('tight');
    title('Power Spectral Density');
	ylabel('Amplitude [dB]','FontWeight','bold');
    xlabel('Frequency [Hz]','FontWeight','bold');
    titleStr = 'PreProcessed moonquake';
    sgtitle({titleStr,filename(4:(end-4))},'FontWeight','bold');
    saveas(hfig,['Plot\03' filename(3:(end-4))],'pdf');
    close (gcf);
end

function [A,RMS] = Deconvolution(ii,filename,A,RMS,LocalCatalog,FlatModeOperationTerm)
    RecordComponent = filename(15);
	RecordType = filename(13:14);
	fileID = fopen(filename);
	eventData = cell2mat(textscan(fileID,'%f %f','headerlines',15));
    fclose(fileID);
    tt = eventData(:,1);
    fs = 1/mean(diff(tt));
    DU = eventData(:,2);
    N = length(DU);
	ShallowNumber = str2double(filename(5:6));
	ShallowStation = str2double(filename(10:11));
	ShallowDate = datetime(str2double(char(LocalCatalog{ShallowNumber,2})),1,str2double(char(LocalCatalog{ShallowNumber,3})));
    fftDU = fft(DU);
	if strcmp(RecordType,'LP')
		LP_Mode = 'P';
		for jj = 1:5
			if (ShallowStation == str2double(char(FlatModeOperationTerm{jj,1})))
				FlatStartTermDate = datetime(str2double(char(FlatModeOperationTerm{jj,2})),str2double(char(FlatModeOperationTerm{jj,3})),str2double(char(FlatModeOperationTerm{jj,4})));
				FlatEndTermDate = datetime(str2double(char(FlatModeOperationTerm{jj,5})),str2double(char(FlatModeOperationTerm{jj,6})),str2double(char(FlatModeOperationTerm{jj,7})));
				if ((ShallowDate >= FlatStartTermDate) && (ShallowDate <=FlatEndTermDate))
					LP_Mode = 'F';
					break
				end
			end
		end
		numa = [5.185e18 0];
		numv = [5.185e18 0 0];
		numd = [5.185e18 0 0 0];
		den = [1 94 3284 6.775e04 9.569e05 9.811e06 7.444e07 4.178e08 1.693e09 4.765e09 9.281e09 1.366e10 8.223e08];
		ha = tf(numa,den);
		hv = tf(numv,den);
		hd = tf(numd,den);
		impulse = tt==0;
		fftha = fft(lsim(ha,impulse,tt)).';
		ffthv = fft(lsim(hv,impulse,tt)).';
		ffthd = fft(lsim(hd,impulse,tt)).';
		k = 0.1;
		wla = k*max(abs(fftha));
		wlv = k*max(abs(ffthv));
		wld = k*max(abs(ffthd));
		if (LP_Mode == 'F')
			numa = [5.185e18 5.17e15 0];
			numv = [5.185e18 5.17e15 0 0];
			numd = [5.185e18 5.17e15 0 0 0];
			den = [1 94 3284 6.737e04 9.395e05 9.415e06 6.859e07 3.571e08 1.245e09 2.441e09 1.468e09 3.729e08 3.127e07 8.199e05];
			ha = tf(numa,den);
			hv = tf(numv,den);
			hd = tf(numd,den);
			fftha = fft(lsim(ha,impulse,tt)).';
			ffthv = fft(lsim(hv,impulse,tt)).';
			ffthd = fft(lsim(hd,impulse,tt)).';
		end
    elseif strcmp(RecordType,'SP')
        numa = [5.761e22 0 0];
        numv = [5.761e22 0 0 0];
        numd = [5.761e22 0 0 0 0];
        den = [1 309.5 4.788e04 4.802e06 3.399e08 1.741e10 6.411e11 1.619e13 2.478e14 1.696e15 4.982e15 1.405e15];
		ha = tf(numa,den);
		hv = tf(numv,den);
		hd = tf(numd,den);
		impulse = tt==0;
		fftha = fft(lsim(ha,impulse,tt)).';
		ffthv = fft(lsim(hv,impulse,tt)).';
		ffthd = fft(lsim(hd,impulse,tt)).';
		k = 0.1;
		lb = 0.001;
        ub = 0.100;
        for jj = 1:size(RMS,1)
            if strcmp(RMS{jj,1}([1:12,14:end]),filename([1:12,14:end]))
                obja = RMS{jj,2};
                objv = RMS{jj,3};
                objd = RMS{jj,4};
                break
            else
                if (jj == size(RMS,1))
					fprintf('%s\n',['SP Deconvolution Error: ' filename]);
                    return
                end
            end
        end
        options = optimoptions(@particleswarm,...
            'Display','off',...
            'FunctionTolerance',1e-3,...
            'InitialSwarmSpan',2000,...
            'MaxIterations',99,...
            'ObjectiveLimit',-Inf,...
            'SelfAdjustmentWeight',1.49,...
            'SocialAdjustmentWeight',1.49);
        ka = particleswarm(@Costa,1,lb,ub,options);
        kv = particleswarm(@Costv,1,lb,ub,options);
        kd = particleswarm(@Costd,1,lb,ub,options);
		wla = ka*max(abs(fftha));
		wlv = kv*max(abs(ffthv));
		wld = kd*max(abs(ffthd));
    end
    for jj = 1:N
        ffta(jj) = (fftDU(jj)*conj(fftha(jj)))/(max(abs(fftha(jj)),wla))^2;
        fftv(jj) = (fftDU(jj)*conj(ffthv(jj)))/(max(abs(ffthv(jj)),wlv))^2;
        fftd(jj) = (fftDU(jj)*conj(ffthd(jj)))/(max(abs(ffthd(jj)),wld))^2;
    end
    acc = real(ifft(ffta));
    vel = real(ifft(fftv));
    des = real(ifft(fftd));
    if strcmp(RecordType,'LP')
	    [b,a] = butter(8,[0.05 0.95*(fs/2)]/(fs/2),'bandpass');
    elseif strcmp(RecordType,'SP')
        [b,a] = butter(6,[0.05 0.95*(fs/2)]/(fs/2),'bandpass');
    end
    acc = detrend(hampel(detrend(filtfilt(b,a,acc)),1000,3.5)).';
    vel = detrend(hampel(detrend(filtfilt(b,a,vel)),1000,3.5)).';
    des = detrend(hampel(detrend(filtfilt(b,a,des)),1000,3.5)).';
    A{ii,1} = tt;
	A{ii,2} = acc;
	A{ii,3} = vel;
	A{ii,4} = des;
    if strcmp(RecordType,'LP')
		RMS{ii,1} = filename;
		[yupper,ylower] = envelope(acc,floor(0.01*length(acc)),'rms');
		RMS{ii,2} = max(max(abs(yupper)),max(abs(ylower)));
		[yupper,ylower] = envelope(vel,floor(0.01*length(vel)),'rms');
		RMS{ii,3} = max(max(abs(yupper)),max(abs(ylower)));
		[yupper,ylower] = envelope(des,floor(0.01*length(des)),'rms');
		RMS{ii,4} = max(max(abs(yupper)),max(abs(ylower)));
    end
    function costa = Costa(k)
        wla = k*max(abs(fftha));
        for jj = 1:N
            ffta(jj) = (fftDU(jj)*conj(fftha(jj)))/(max(abs(fftha(jj)),wla))^2;
        end
        acc = real(ifft(ffta));
        [b,a] = butter(6,[0.05 0.95*(fs/2)]/(fs/2),'bandpass');
        acc = detrend(hampel(detrend(filtfilt(b,a,acc)),1000,3.5)).';
		[yupper,ylower] = envelope(acc,floor(0.01*length(acc)),'rms');
        costa = abs(obja - max(max(abs(yupper)),max(abs(ylower))));
	end
    function costv = Costv(k)
        wlv = k*max(abs(ffthv));
        for jj = 1:N
            fftv(jj) = (fftDU(jj)*conj(ffthv(jj)))/(max(abs(ffthv(jj)),wlv))^2;
        end
		vel = real(ifft(fftv));
        [b,a] = butter(6,[0.05 0.95*(fs/2)]/(fs/2),'bandpass');
        vel = detrend(hampel(detrend(filtfilt(b,a,vel)),1000,3.5)).';
		[yupper,ylower] = envelope(vel,floor(0.01*length(vel)),'rms');
        costv = abs(objv - max(max(abs(yupper)),max(abs(ylower))));
	end
    function costd = Costd(k)
        wld = k*max(abs(ffthd));
        for jj = 1:N
            fftd(jj) = (fftDU(jj)*conj(ffthd(jj)))/(max(abs(ffthd(jj)),wld))^2;
        end
		des = real(ifft(fftd));
        [b,a] = butter(6,[0.05 0.95*(fs/2)]/(fs/2),'bandpass');
        des = detrend(hampel(detrend(filtfilt(b,a,des)),1000,3.5)).';
		[yupper,ylower] = envelope(des,floor(0.01*length(des)),'rms');
        costd = abs(objd - max(max(abs(yupper)),max(abs(ylower))));
	end
end

function SaveDeconvolved(ii,filename,A)
    B = [A{ii,1} A{ii,2}];
    fs = 1/mean(diff(B(:,1)));
    N = length(B(:,1));
    fid = fopen(['Acc\Acc' filename(3:end)],'wt');
	fprintf(fid,'%s\n',['% Date: ' datestr(now, 'dd/mmmm/yyyy-HH:MM:SS')]);
	fprintf(fid,'%s\n','% Deconvolved Apollo Accelerogram record');
	fprintf(fid,'%s\n',['% File: Acc' filename(3:end)]);
	fprintf(fid,'%s\n',['% Event: ' filename(4:6)]);
	fprintf(fid,'%s\n',['% Station: ' filename(10:11)]);
	fprintf(fid,'%s\n',['% Record Type:' filename(13:14)]);
	fprintf(fid,'%s\n',['% Component: ' filename(15)]);
	fprintf(fid,'%s\n','% First Column: Time (s)');
	fprintf(fid,'%s\n','% Second Column: Acceleration (m*s^{-2})');
	fprintf(fid,'%s\n','% Matlab Loading Method:');
	fprintf(fid,'%s\n',['% fileID = fopen(''Acc' filename(3:end) ''');']);
	fprintf(fid,'%s\n','% Data = cell2mat(textscan(fileID,''%f %f'',''headerlines'',15));');
	fprintf(fid,'%s\n','% fclose(fileID);');
	fprintf(fid,'\n');
	fprintf(fid,'\n');
    for jj = 1:size(B,1)
        fprintf(fid,'%6.6f\t%.6e',B(jj,:));
        fprintf(fid,'\n');
    end 
    fclose(fid);
    hfig = figure('Visible','off');
	subplot(2,1,1);
    plot(B(:,1),B(:,2));
    grid on;
    xmax = max(B(:,1));
    ymax = 1.1*max(abs(B(:,2)));
    axis([0 xmax -ymax ymax]);
    title('Accelerogram');
    ylabel('Acceleration [m*s^{-2}]','FontWeight','bold');
    xlabel('Time [s]','FontWeight','bold');
	subplot(2,1,2);
	nfft = 2^(nextpow2(N)-7);
	noverlap = nfft/2;
	window = nfft;
	[psd,ff] = pwelch(B(:,2),nfft,noverlap,window,fs);
	semilogx(ff,db(psd));
    grid on;
    axis('tight');
    title('Power Spectral Density');
	ylabel('Amplitude [dB]','FontWeight','bold');
    xlabel('Frequency [Hz]','FontWeight','bold');
    titleStr = 'Deconvolved moonquake in acceleration';
    sgtitle({titleStr,filename(4:(end-4))},'FontWeight','bold');
    saveas(hfig,['Plot\Acc\Acc',filename(3:(end-4))],'pdf');
    close(gcf);
	B = [A{ii,1} A{ii,3}];
    fs = 1/mean(diff(B(:,1)));
    N = length(B(:,1));
    fid = fopen(['Vel\Vel' filename(3:end)],'wt');
	fprintf(fid,'%s\n',['% Date: ' datestr(now, 'dd/mmmm/yyyy-HH:MM:SS')]);
	fprintf(fid,'%s\n','% Deconvolved Apollo Velocity record');
	fprintf(fid,'%s\n',['% File: Vel' filename(3:end)]);
	fprintf(fid,'%s\n',['% Event: ' filename(4:6)]);
	fprintf(fid,'%s\n',['% Station: ' filename(10:11)]);
	fprintf(fid,'%s\n',['% Record Type:' filename(13:14)]);
	fprintf(fid,'%s\n',['% Component: ' filename(15)]);
	fprintf(fid,'%s\n','% First Column: Time (s)');
	fprintf(fid,'%s\n','% Second Column: Velocity (m*s^{-1})');
	fprintf(fid,'%s\n','% Matlab Loading Method:');
	fprintf(fid,'%s\n',['% fileID = fopen(''Vel' filename(3:end) ''');']);
	fprintf(fid,'%s\n','% Data = cell2mat(textscan(fileID,''%f %f'',''headerlines'',15));');
	fprintf(fid,'%s\n','% fclose(fileID);');
	fprintf(fid,'\n');
	fprintf(fid,'\n');
    for jj = 1:size(B,1)
        fprintf(fid,'%6.6f\t%.6e',B(jj,:));
        fprintf(fid,'\n');
    end 
    fclose(fid);
    hfig = figure('Visible','off');
	subplot(2,1,1);
    plot(B(:,1),B(:,2));
    grid on;
    xmax = max(B(:,1));
    ymax = 1.1*max(abs(B(:,2)));
    axis([0 xmax -ymax ymax]);
    title('Velocity Diagram');
    ylabel('Velocity [m*s^{-1}]','FontWeight','bold');
    xlabel('Time [s]','FontWeight','bold');
	subplot(2,1,2);
	nfft = 2^(nextpow2(N)-7);
	noverlap = nfft/2;
	window = nfft;
	[psd,ff] = pwelch(B(:,2),nfft,noverlap,window,fs);
	semilogx(ff,db(psd));
    grid on;
    axis('tight');
    title('Power Spectral Density');
	ylabel('Amplitude [dB]','FontWeight','bold');
    xlabel('Frequency [Hz]','FontWeight','bold');
    titleStr = 'Deconvolved moonquake in velocity';
    sgtitle({titleStr,filename(4:(end-4))},'FontWeight','bold');
    saveas(hfig,['Plot\Vel\Vel',filename(3:(end-4))],'pdf');
    close(gcf);
	B = [A{ii,1} A{ii,4}];
    fs = 1/mean(diff(B(:,1)));
    N = length(B(:,1));
    fid = fopen(['Dis\Dis' filename(3:end)],'wt');
	fprintf(fid,'%s\n',['% Date: ' datestr(now, 'dd/mmmm/yyyy-HH:MM:SS')]);
	fprintf(fid,'%s\n','% Deconvolved Apollo Displacement record');
	fprintf(fid,'%s\n',['% File: Dis' filename(3:end)]);
	fprintf(fid,'%s\n',['% Event: ' filename(4:6)]);
	fprintf(fid,'%s\n',['% Station: ' filename(10:11)]);
	fprintf(fid,'%s\n',['% Record Type:' filename(13:14)]);
	fprintf(fid,'%s\n',['% Component: ' filename(15)]);
	fprintf(fid,'%s\n','% First Column: Time (s)');
	fprintf(fid,'%s\n','% Second Column: Displacement (m)');
	fprintf(fid,'%s\n','% Matlab Loading Method:');
	fprintf(fid,'%s\n',['% fileID = fopen(''Dis' filename(3:end) ''');']);
	fprintf(fid,'%s\n','% Data = cell2mat(textscan(fileID,''%f %f'',''headerlines'',15));');
	fprintf(fid,'%s\n','% fclose(fileID);');
	fprintf(fid,'\n');
	fprintf(fid,'\n');
    for jj = 1:size(B,1)
        fprintf(fid,'%6.6f\t%.6e',B(jj,:));
        fprintf(fid,'\n');
    end 
    fclose(fid);
    hfig = figure('Visible','off');
	subplot(2,1,1);
    plot(B(:,1),B(:,2));
    grid on;
    xmax = max(B(:,1));
    ymax = 1.1*max(abs(B(:,2)));
    axis([0 xmax -ymax ymax]);
    title('Displacement Diagram');
    ylabel('Displacement [m]','FontWeight','bold');
    xlabel('Time [s]','FontWeight','bold');
	subplot(2,1,2);
	nfft = 2^(nextpow2(N)-7);
	noverlap = nfft/2;
	window = nfft;
	[psd,ff] = pwelch(B(:,2),nfft,noverlap,window,fs);
	semilogx(ff,db(psd));
    grid on;
    axis('tight');
    title('Power Spectral Density');
	ylabel('Amplitude [dB]','FontWeight','bold');
    xlabel('Frequency [Hz]','FontWeight','bold');
    titleStr = 'Deconvolved moonquake in displacement';
    sgtitle({titleStr,filename(4:(end-4))},'FontWeight','bold');
    saveas(hfig,['Plot\Dis\Dis',filename(3:(end-4))],'pdf');
    close(gcf);
end