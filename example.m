% Load the data. Call this once outside of the script so you dont have to
% load the data again and again. Make sure the dataset is included in your
% Matlab path
% sess = ssveptoolkit.util.Session;
% sess.loadAll(); %its best to do this once, outside the script (too much
% time)

%Load a filter from the samples
load filt_FIR_Equir_400coef;
%Extract features with the pwelch method
extr = ssveptoolkit.featextraction.PWelchExperimental;
extr.nfft = 512;
extr.win_len = 350;
extr.over_len = 0.75;

amu = ssveptoolkit.preprocessing.Amuse;
amu.first = 15;
amu.last = 252;
refer = ssveptoolkit.preprocessing.Rereferencing;
%Subtract the mean from the signal
refer.meanSignal = 1;

ss = ssveptoolkit.preprocessing.SampleSelection;
ss.sampleRange = [1,1250]; % Specify the sample range to be used for each Trial
ss.channels = 138; % Specify the channel(s) to be used

df = ssveptoolkit.preprocessing.DigitalFilter; % Apply a filter to the raw data
df.filt = Hbp; % Hbp is a filter built with "filterbuilder" matlab function

svd = ssveptoolkit.featselection.SVD;
svd.modes = 90;
%Configure the classifier
classif = ssveptoolkit.classification.LIBSVMFast;
classif.kernel = 'spearman';
classif.cost = 1;

%Set the Experimenter wrapper class
experiment = ssveptoolkit.experiment.Experimenter;
experiment.session = sess;
% Add the preprocessing steps (order is taken into account)
experiment.preprocessing = {ss,refer,df};
experiment.featselection = svd;
experiment.featextraction = extr;
experiment.classification = classif;
experiment.evalMethod = experiment.EVAL_METHOD_LOSO; % specify that you want a "leave one subject out" (default is LOOCV)
experiment.run();
for i=1:length(experiment.results)
    accuracies(i) = experiment.results{i}.getAccuracy();
end

accuracies'
%mean accuracy for all subjects
fprintf('mean acc = %f\n', mean(accuracies));
%get the configuration used (for reporting)
experiment.getExperimentInfo
experiment.getTime