import serial
import time

ser = serial.Serial('COM3',115200)

time.sleep(2)

print("Sending lines...")

with open("Pathofgcodefile.gcode", "r") as f:

    for line in f:

        line=line.strip()

        if line:

            print("Sent:", line)

            ser.write((line+'\n').encode())

            time.sleep(0.2)

print("Done!")

ser.close()
