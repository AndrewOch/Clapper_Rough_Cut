import librosa
from sklearn.preprocessing import MinMaxScaler
from dtw import dtw
import numpy as np

hop_length = 1024

def get_normalized_mfcc(audio_file):
    y, sr = librosa.load(audio_file)
    y, y_percussive = librosa.effects.hpss(y)
    mfcc = librosa.feature.mfcc(y=y, sr=16000, hop_length=hop_length, norm=None, n_mfcc=20)
    scaler = MinMaxScaler(feature_range=(0, 1))
    mfcc_norm = scaler.fit_transform(mfcc)
    return mfcc_norm.T


def get_dtw(mfccs1, mfccs2):
    mfccs1 = np.array(mfccs1)
    mfccs2 = np.array(mfccs2)
    dist = dtw(mfccs1, mfccs2, dist=lambda x, y: np.linalg.norm(x - y, ord=1))
    return dist


def get_dtw_offset(mfccs1, mfccs2):
    mfccs1 = np.array(mfccs1)
    mfccs2 = np.array(mfccs2)
    dist, cost, acc_cost, path = dtw(mfccs1, mfccs2, dist=lambda x, y: np.linalg.norm(x - y, ord=1))
    offset = path[0][-1] - path[1][-1]
    time_offset = int(offset * (hop_length / 16000))
    return dist, time_offset
