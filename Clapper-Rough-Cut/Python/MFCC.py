import librosa
from sklearn.preprocessing import MinMaxScaler
from dtw import dtw
import numpy as np


def get_normalized_mfcc(audio_file):
    y, sr = librosa.load(audio_file)
    y, y_percussive = librosa.effects.hpss(y)
    mfcc = librosa.feature.mfcc(y=y, sr=sr)
    scaler = MinMaxScaler(feature_range=(0, 1))
    mfcc_norm = scaler.fit_transform(mfcc)
    return mfcc_norm.T


def get_dtw(mfccs1, mfccs2):
    mfccs1 = np.array(mfccs1)
    mfccs2 = np.array(mfccs2)
    dist = dtw(mfccs1, mfccs2, dist=lambda x, y: np.linalg.norm(x - y, ord=1))
    return dist
