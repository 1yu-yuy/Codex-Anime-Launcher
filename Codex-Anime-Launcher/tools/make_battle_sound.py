"""Original four-second heavy battle-rock cue synchronized to Zoro's cuts."""
import numpy as np
import wave
from pathlib import Path

sr=44100
duration=4.08
n=int(duration*sr)
mix=np.zeros((n,2),dtype=np.float64)
rng=np.random.default_rng(314159)

def put(at,sound,level=1,pan=0):
    start=int(at*sr)
    sound=np.asarray(sound)[:n-start]
    if sound.ndim==1:
        sound=sound[:,None]*np.array([np.sqrt((1-pan)/2),np.sqrt((1+pan)/2)])
    mix[start:start+len(sound)]+=sound*level

def times(length):
    return np.arange(int(length*sr))/sr

def noise(t,low,high):
    a=rng.normal(0,1,len(t))
    f=np.fft.rfftfreq(len(a),1/sr)
    mask=(1-np.exp(-(f/max(low,1))**4))*np.exp(-(f/high)**4)
    return np.fft.irfft(np.fft.rfft(a)*mask,n=len(a))

def guitar(freq,length,detune=1,muted=True):
    t=times(length)
    s=np.zeros(len(t))
    # Detuned root, fifth, octave through a saturating amplifier and cabinet.
    for ratio,amp in [(1,1),(1.4983,.8),(2,.45)]:
        phase=2*np.pi*freq*ratio*detune*t
        for h in range(1,19):
            s+=amp*np.sin(phase*h+.15*h)/(h**.86)
    env=(1-np.exp(-t*1400))*np.exp(-t*(14 if muted else 2.4))
    env*=np.minimum(1,(length-t)/.035)
    s=np.tanh(s*2.8)*env
    f=np.fft.rfftfreq(len(s),1/sr)
    cab=(1-np.exp(-(f/75)**4))*np.exp(-(f/3900)**2)
    return np.fft.irfft(np.fft.rfft(s)*cab,n=len(s))

def kick(at,level=1):
    t=times(.32)
    phase=2*np.pi*(47*t+110*(1-np.exp(-t*45))/45)
    s=np.sin(phase)*np.exp(-t*15)+.11*noise(t,2200,7500)*np.exp(-t*220)
    put(at,s,level)

def snare(at,level=1):
    t=times(.24)
    s=(.66*noise(t,900,8500)*np.exp(-t*20)+.4*np.sin(2*np.pi*185*t)*np.exp(-t*30))
    s*=1-np.exp(-t*1800)
    put(at,s,level)

def cymbal(at,length=.7,level=.25,pan=.35):
    t=times(length)
    ring=sum(np.sin(2*np.pi*f*t) for f in [3461,4213,5399,6841])/4
    s=(.75*noise(t,4500,15000)+.25*ring)*np.exp(-t*(5 if length>.3 else 35))
    s*=np.minimum(1,(length-t)/.035)
    put(at,s,level,pan)

beat=60/174
for k in range(17):
    at=.025+k*beat/2
    if at>2.88:break
    note=[73.416,73.416,73.416,87.307,73.416,97.999,110,97.999][k%8]
    long=k in [3,7,11,15]
    for pan,detune in [(-.86,.998),(.86,1.002)]:
        put(at,guitar(note,.32 if long else .205,detune,not long),.39,pan)
    kick(at,.82 if k%2==0 else .53)
    cymbal(at,.11,.1,(-.4 if k%2 else .4))
    if k%4==2:snare(at,.87)

cymbal(.025,1.15,.3,-.4)
cymbal(1.405,.85,.23,.4)
# Low battle drums and a tightening fill ahead of the sword attack.
for j,at in enumerate([.04,.39,.73,1.08,1.42,1.77,2.12,2.46,2.64,2.76,2.86]):
    t=times(.28)
    f=80 if j%2 else 62
    phase=2*np.pi*(f*t+42*(1-np.exp(-t*30))/30)
    s=(np.sin(phase)+.2*np.sin(phase*1.59))*np.exp(-t*12)
    put(at,s,.28,(-.35 if j%2 else .35))
for at in [2.64,2.76,2.86]:snare(at,.4)

# Air pull-in during Zoro's enlargement, then an intentional pre-cut gap.
t=times(.81)
phase=2*np.pi*(130*t+1250*t**3/3)
riser=(noise(t,1200,6500)*.22+np.sin(phase)*.08)*(t/.81)**2
put(2.15,riser,.6)
mix[int(2.97*sr):int(3.045*sr)]*=.05

for k,at in enumerate([3.05,3.12,3.19]):
    t=times(.31)
    phase=2*np.pi*(135*t+2300*(1-np.exp(-t*24))/24)
    s=(noise(t,1400,10500)*.42+np.sin(phase)*.22)*np.exp(-t*18)
    s*=1-np.exp(-t*1800)
    put(at,s,.88,[-.75,.75,0][k])

# Full distorted power chord, sub impact and crash land on the third sword.
for pan,detune in [(-.85,.997),(.85,1.003)]:
    put(3.23,guitar(73.416,.83,detune,False),.46,pan)
kick(3.23,1.05)
snare(3.23,.7)
cymbal(3.23,.84,.38)
t=times(.77)
sub=np.sin(2*np.pi*(39*t+75*(1-np.exp(-t*22))/22))*np.exp(-t*6)
put(3.23,sub,.42)

dry=mix.copy()
for delay,level in [(.047,.11),(.093,.07),(.167,.035)]:
    shift=int(delay*sr)
    mix[shift:]+=dry[:-shift,::-1]*level
# A soft limiter brings the short cue forward without hard clipping.
lo,hi=.1,8
for _ in range(25):
    drive=(lo+hi)/2
    limited=.89*np.tanh(mix*drive)
    if np.sqrt(np.mean(limited**2))<.235:lo=drive
    else:hi=drive
mix=.89*np.tanh(mix*((lo+hi)/2))
fade=np.minimum(1,np.arange(n)/(sr*.008))*np.minimum(1,(n-1-np.arange(n))/(sr*.065))
mix*=fade[:,None]
pcm=(mix*32767).astype('<i2')
path=Path(__file__).resolve().parents[1] / 'assets' / 'startup-sfx.wav'
with wave.open(str(path),'wb') as f:
    f.setnchannels(2);f.setsampwidth(2);f.setframerate(sr);f.writeframes(pcm.tobytes())
print(f'{duration}s battle rock; peak {np.max(np.abs(mix)):.3f}; RMS {np.sqrt(np.mean(mix**2)):.3f}')
