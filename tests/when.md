---
sidebar_position: 3
---

# When To Serialize?

Strings are great for serializing data, but we need to know when to serialize. We should serialize when we need to send data over the network or store it in data banks. However, certain kinds of data is cheaper to send over the network than others. Below are empirically measured throughputs of different kinds of types, lengths, and amounts.

To generate a JSON file of the test results you can download (this place file)[#] and run it in studio. Just be warned, it will take a few hours to complete. The results are measured using the Stats service's DataRecieveKbps property 2000 times every 1-3 frames once the recieve rate has stabilized. It waits for the recieve rate to plateau at 0.15kb/s before starting the test, then waits 10 seconds to allow the averaged Stats.DataReceiveKbps to plateau at the maximum value before starting the measurements. Then it appends the current Stats.DataReceiveKbps value to an array every 1-3 frames 2000 times. The process is repeated for all the different kinds of data, which takes a while.

The results below have had much care put into them, and are now here for your display. Enjoy!

## Results
...

| Value | Bandwidth (KB/s) | Notes | Conclusions |
|-|-|-|-|
| noise | ±0.02 | Noise from environment and other factors |
| baseline | 0.16 | | Roblox is constantly sending data in the background |
| `()` | 0.85 | Testing if remote event has a cost | Yes |
| `(nil)` | 0.91 | Testing if nil is the same as void | No. |
| `(true)`, `(false)`, `('')` | 0.97 | Testing if value changes cost | No. Only serialize 2 or more booleans for optimal results |
| `('\0')`, `('a')`, `('0')` | 1.03 | Testing if value changes cost | No. Past this point, it is better to serialize to strings |
| `('aa')`, `('', '')` | 1.09 |
| `(true, false)`, `(false, true)`, `({true})` | 1.10 | Testing if bitpacked. Testing if order changes cost | No. No |
| `('aaa')`, `(Vector2int16.new(-32768, 9274))` | 1.16 |
| `(true, true, true)`, `('aaaa')`, `('a', 'a')`, `({true, true})`, `('', '', '')` | 1.22 | Empty string cost measured | Empty string cost averages 0.12 KB/s. Separating arguments is costly!
| `('aaaaa')`, `(Vector3int16.new(-32768, 9274, 32767))` | 1.28 |
| `(true, true, true, true)` | 1.34 |
| `('aaaaaa')` | 1.35 |
| `(Vector2.zero), (Vector2.one)`, `(Vector2.new(-32768, 32767))` | 1.40 | Testing if value changes cost | No |
| `('aaaaaaa')`, `('a', 'a', 'a')`, `(0)`, `(-96495734574.4864)` | 1.41 | Testing if value changes cost | No |
| `(true, true, true, true, true)`, `('aaaaaaaa')` | 1.47 | Character cost measured | Character cost averages 0.07 KB/s |
| `(true, true, true, true, true, true)`, `('a', 'a', 'a', 'a')` | 1.60 |
| `(Vector3.zero)`, `(Vector3.one)`, `(Vector3.new(-2402.39, 938403, 2057492.4953))` | 1.66 | Testing if value changes cost | No |
| `(true, true, true, true, true, true, true)`, `(CFrame.identity)`, `(CFrame.new() + Vector3.new(938, 0, 0))` | 1.73 | | The CFrame's position is always sent |
| `('a', 'a', 'a', 'a', 'a')` | 1.79 | Cost measured | String cost averages 0.19 KB/s |
| `(true, true, true, true, true, true, true, true)` | 1.86 | Cost measured | Boolean cost averages 0.13 KB/s |
| `(0, 0)` | 1.98 |
| `((CFrame.fromEulerAngles(9, 2, -5.3))`, `(CFrame.fromEulerAngles(9, 2, -5.3) + Vector3.new(938, 0, 0))` | 2.10 | Investigating if position and rotation are sent separately | The rotation is sent separately, and only if it needs to be sent |
| `(0, 0, 0)` | 2.54 | Dang |
| `(0, 0, 0, 0)` | 3.10 | Cost measured | Number cost averages 0.56 KB/s. Numbers are expensive! Sad |

Main takeaways:
- Arguments have overhead! Avoid separating arguments if possible!
- Numbers are expensive! Avoid sending numbers! ***Even CFrames can be cheaper.***
- Booleans are cheap! Don't serialize a single boolean. Serialize 2 or more booleans at a time!
- Strings are cheap! Serialize to strings!
- Nil takes up space!!! Don't send nils for no reason!!!!!!!!