#!/usr/bin/env python3
# airpods.py — scans Apple's BLE advertisement and writes AirPods battery to
# /tmp/airpods.json so a waybar module can show it. Decoding logic adapted from
# AirStatus (delphiki/AirStatus); BLE scanning rewritten for modern bleak (3.x).
import asyncio
import json
import sys
from binascii import hexlify
from time import time

from bleak import BleakScanner

AIRPODS_MANUFACTURER = 76          # Apple, company id 0x004C
AIRPODS_DATA_LENGTH = 54           # hex chars (27 bytes)
MIN_RSSI = -70                     # ignore far-away (other people's) AirPods
OUTPUT = "/tmp/airpods.json"
SCAN_TIMEOUT = 5                   # seconds of scanning per cycle
IDLE_SLEEP = 10                    # gap between scans (low radio contention)

MODELS = {
    "e": "AirPods Pro", "3": "AirPods 3", "f": "AirPods 2",
    "2": "AirPods 1", "a": "AirPods Max", "b": "AirPods Pro 2",
}


def _is_flipped(raw):
    return (int(chr(raw[10]), 16) & 0x02) == 0


def _charge(c):
    v = int(chr(c), 16)
    return 100 if v == 10 else (v * 10 + 5 if v < 10 else -1)


def decode(data_bytes):
    raw = hexlify(bytearray(data_bytes))
    if len(raw) != AIRPODS_DATA_LENGTH:
        return None
    flip = _is_flipped(raw)
    cs = int(chr(raw[14]), 16)
    return dict(
        status=1,
        model=MODELS.get(chr(raw[7]), "AirPods"),
        left=_charge(raw[12 if flip else 13]),
        right=_charge(raw[13 if flip else 12]),
        case=_charge(raw[15]),
        charging_left=bool(cs & (0b10 if flip else 0b01)),
        charging_right=bool(cs & (0b01 if flip else 0b10)),
        charging_case=bool(cs & 0b100),
    )


async def scan_once():
    devices = await BleakScanner.discover(timeout=SCAN_TIMEOUT, return_adv=True)
    best, best_rssi = None, -999
    for _addr, (_dev, adv) in devices.items():
        md = adv.manufacturer_data.get(AIRPODS_MANUFACTURER)
        if md and adv.rssi >= MIN_RSSI and adv.rssi > best_rssi:
            d = decode(md)
            if d:
                best, best_rssi = d, adv.rssi
    return best


async def loop():
    while True:
        try:
            res = await scan_once()
        except Exception:
            res = None
        if res is None:
            res = dict(status=0)
        res["ts"] = int(time())
        with open(OUTPUT, "w") as f:
            json.dump(res, f)
        await asyncio.sleep(IDLE_SLEEP)


if __name__ == "__main__":
    if "--once" in sys.argv:
        print(json.dumps(asyncio.run(scan_once())))
    else:
        asyncio.run(loop())
