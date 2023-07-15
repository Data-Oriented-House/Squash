---
sidebar_position: 5
---

# Benchmarks and Measurements

## Eyeballed Lookup Table

Before we had access to the raw binary data, we ran benchmarks! Below is our first attempt at measuring bandwidth. Is is an eye-measured median of the incoming kB/s from the Networking window in studio after stabilization. The code is on the server and fires a remote with the Value every task.wait().

| Value | Median Bandwidth (kB/s) | Notes | Conclusions |
|-|-|-|-|
| noise | ±0.02 | Noise from environment and other factors |
| baseline | 0.16 | | Roblox is constantly sending data in the background |
| `()` | 0.85 | Testing if remote event has a cost | Yes |
| `(nil)` | 0.91 | Testing if nil is the same as void | No. |
| `(true)`, `(false)`, `('')` | 0.97 | Testing if value changes cost | No. Only serialize 2 or more booleans for optimal results |
| `('\0')`, `('a')`, `('0')` | 1.03 | Testing if value changes cost | No. Past this point, it is better to serialize to strings |
| `('aa')`, `('', '')` | 1.09 |
| `(true, false)`, `(false, true)`, `({true})` | 1.10 | Testing if bit-packed. Testing if order changes cost | No. No |
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

### Main takeaways:
- Arguments have overhead! Avoid separating arguments if possible!
- Numbers are expensive! Avoid sending numbers! ***Even CFrames can be cheaper.***
- Booleans are cheap! Don't serialize a single boolean. Serialize 2 or more booleans at a time!
- Strings are cheap! Serialize to strings!
- Nil takes up space!!! Don't send nils for no reason!!!!!!!!

### How Can I Trust These Results?

To now compare these results with the binary data above, we can take the difference between two median rates, and compare them with the theoretical difference in bytes. Sending `()` has a rate of `0.85 kB/s`, and sending `('aa')` has a rate of `1.09 kB/s`. The difference is `0.24 kB/s`.

Now to apply theory, the binary suggests that `'aa'` uses 1 byte for the type, 1 byte for the length, and 2 bytes for the characters. This means `4 bytes`. The rate of these measurements is 60 times a second. This means that the theoretical difference in bytes is `4 Bytes * 60 / second = 240 Bytes / second`. This means that the theoretical difference in kB/s is `0.24 kB/s`. This is the same as the measured difference in kB/s. This leads us to believe that the binary data is correct, and that the measurements above are accurate as well. This also means the Network Stats window displays Kilobytes instead of Kibibytes.

## Proper Benchmarks

Below is our second attempt to measure, using different benchmarks that verifies the above table with better accuracy.

To generate a JSON file of the test below results you can download [this place file](/netbench.rbxl) and run it in studio. For the json file of this benchmark presented on this page you can download [this json file](/Data.json). Just be warned, it will take a few hours to complete. The results are measured using the Stats service's DataRecieveKbps property 2000 times every 1-3 frames once the recieve rate has stabilized. It waits for the recieve rate to plateau at 0.15kb/s before starting the test, then waits 10 seconds to allow the averaged Stats.DataReceiveKbps to plateau at the maximum value before starting the measurements. Then it appends the current Stats.DataReceiveKbps value to an array every 1-3 frames 2000 times. The process is repeated for all the different kinds of data, which takes a while.

### How Can I Trust These Results?

To compare these results with the binary data above, we can take the difference between two median rates, and compare them with the theoretical difference in bytes. Sending `()` has a rate of `0.783 kB/s`, and sending `(7)` has a rate of `1.323 kB/s`. The difference is `0.540 kB/s`.

Now to apply theory, the binary suggests that `(7)` uses 1 byte for the type and 8 bytes for the number. This means `9 Bytes`. The rate of these measurements is 60 times a second. This means that the theoretical difference in bytes is `9 Bytes * 60 / Second = 540 Bytes / second`. This means that the theoretical difference in kB/s is `0.540 kB/s`. This is the same as the measured difference in kB/s. This leads us to believe that the binary data is correct, and that the measurements below are accurate as well. This also means that the Stats service displays Kilobytes instead of Kibibytes.

## Results

### ()

![()](/benchmarks/1.webp)

### ('')

![('')](/benchmarks/84.webp)

### (true)

![(true)](/benchmarks/80.webp)

### (false)

![(false)](/benchmarks/77.webp)

### ({})

![({})](/benchmarks/0.webp)

### ('A')

![('A')](/benchmarks/131.webp)

### (string.char(255))

![(string_char(255))](/benchmarks/133.webp)

### ('a')

![('a')](/benchmarks/160.webp)

### (string.char(0))

![(string_char(0))](/benchmarks/111.webp)

### ({true})

![({true})](/benchmarks/79.webp)

### ('aa')

![('aa')](/benchmarks/126.webp)

### (true, false)

![(true, false)](/benchmarks/78.webp)

### ({''})

![({''})](/benchmarks/86.webp)

### ('', '')

![('', '')](/benchmarks/95.webp)

### (Vector2int16.new(1, -3))

![(Vector2int16_new(1, -3))](/benchmarks/105.webp)

### (Vector2int16.new(-1, -3))

![(Vector2int16_new(-1, -3))](/benchmarks/109.webp)

### (Vector2int16.new(-1, 3))

![(Vector2int16_new(-1, 3))](/benchmarks/104.webp)

### ('aaa')

![('aaa')](/benchmarks/120.webp)

### (Vector2int16.new(1, 3))

![(Vector2int16_new(1, 3))](/benchmarks/102.webp)

### (true, false, true)

![(true, false, true)](/benchmarks/75.webp)

### ('aaaa')

![('aaaa')](/benchmarks/134.webp)

### ('', '', '')

![('', '', '')](/benchmarks/90.webp)

### ({'', ''})

![({'', ''})](/benchmarks/100.webp)

### ({true, false})

![({true, false})](/benchmarks/81.webp)

### ('a', 'a')

![('a', 'a')](/benchmarks/60.webp)

### ({Vector2int16.new(-1, 3)})

![({Vector2int16_new(-1, 3)})](/benchmarks/103.webp)

### (Vector3int16.new(1, 3, 5))

![(Vector3int16_new(1, 3, 5))](/benchmarks/41.webp)

### (Vector3int16.new(-1, 3, -5))

![(Vector3int16_new(-1, 3, -5))](/benchmarks/36.webp)

### (Vector3int16.new(1, -3, 5))

![(Vector3int16_new(1, -3, 5))](/benchmarks/39.webp)

### (Vector3int16.new(-1, -3, -5))

![(Vector3int16_new(-1, -3, -5))](/benchmarks/38.webp)

### ('aaaaa')

![('aaaaa')](/benchmarks/119.webp)

### ({'a', 'a'})

![({'a', 'a'})](/benchmarks/61.webp)

### ('', '', '', '')

![('', '', '', '')](/benchmarks/87.webp)

### (true, false, true, false)

![(true, false, true, false)](/benchmarks/69.webp)

### ('aaaaaa')

![('aaaaaa')](/benchmarks/158.webp)

### ({true, false, true})

![({true, false, true})](/benchmarks/71.webp)

### ({'', '', ''})

![({'', '', ''})](/benchmarks/99.webp)

### (Vector2.zero)

![(Vector2_zero)](/benchmarks/31.webp)

### (0)

![(0)](/benchmarks/9.webp)

### (18375)

![(18375)](/benchmarks/17.webp)

### ({Vector3int16.new(-1, 3, -5)})

![({Vector3int16_new(-1, 3, -5)})](/benchmarks/40.webp)

### (Vector2.new(-1, 2.5))

![(Vector2_new(-1, 2_5))](/benchmarks/28.webp)

### ('a', 'a', 'a')

![('a', 'a', 'a')](/benchmarks/58.webp)

### (Vector2.new(-1, -2.73))

![(Vector2_new(-1, -2_73))](/benchmarks/25.webp)

### ('aaaaaaa')

![('aaaaaaa')](/benchmarks/161.webp)

### (-18375)

![(-18375)](/benchmarks/14.webp)

### (Vector2.new(1, -2))

![(Vector2_new(1, -2))](/benchmarks/29.webp)

### (Vector2.one)

![(Vector2_one)](/benchmarks/24.webp)

### (Vector2.new(1, 2))

![(Vector2_new(1, 2))](/benchmarks/22.webp)

### (Vector2int16.new(-1, 3), Vector2int16.new(-1, 3))

![(Vector2int16_new(-1, 3), Vector2int16_new(-1, 3))](/benchmarks/106.webp)

### ('aaaaaaaa')

![('aaaaaaaa')](/benchmarks/113.webp)

### ({true, false, true, false})

![({true, false, true, false})](/benchmarks/67.webp)

### ({'', '', '', ''})

![({'', '', '', ''})](/benchmarks/92.webp)

### ('', '', '', '', '')

![('', '', '', '', '')](/benchmarks/98.webp)

### (true, false, true, false, true)

![(true, false, true, false, true)](/benchmarks/70.webp)

### ('aaaaaaaaa')

![('aaaaaaaaa')](/benchmarks/117.webp)

### ({0})

![({0})](/benchmarks/18.webp)

### ({'a', 'a', 'a'})

![({'a', 'a', 'a'})](/benchmarks/54.webp)

### ({Vector2.new(1, 2)})

![({Vector2_new(1, 2)})](/benchmarks/23.webp)

### ({Vector2int16.new(-1, 3), Vector2int16.new(-1, 3)})

![({Vector2int16_new(-1, 3), Vector2int16_new(-1, 3)})](/benchmarks/107.webp)

### ('', '', '', '', '', '')

![('', '', '', '', '', '')](/benchmarks/96.webp)

### ({'', '', '', '', ''})

![({'', '', '', '', ''})](/benchmarks/101.webp)

### ('aaaaaaaaaa')

![('aaaaaaaaaa')](/benchmarks/140.webp)

### ('a', 'a', 'a', 'a')

![('a', 'a', 'a', 'a')](/benchmarks/62.webp)

### (true, false, true, false, true, false)

![(true, false, true, false, true, false)](/benchmarks/83.webp)

### ({true, false, true, false, true})

![({true, false, true, false, true})](/benchmarks/68.webp)

### (Vector3.one)

![(Vector3_one)](/benchmarks/49.webp)

### (Vector3.zero)

![(Vector3_zero)](/benchmarks/45.webp)

### (Vector3.new(1, -2, 3))

![(Vector3_new(1, -2, 3))](/benchmarks/48.webp)

### (Vector3.new(1, 2, 3))

![(Vector3_new(1, 2, 3))](/benchmarks/47.webp)

### (Vector3.new())

![(Vector3_new())](/benchmarks/51.webp)

### ('aaaaaaaaaaa')

![('aaaaaaaaaaa')](/benchmarks/146.webp)

### (Vector3.new(-1, 2.5, -3.27))

![(Vector3_new(-1, 2_5, -3_27))](/benchmarks/42.webp)

### (CFrame.identity)

![(CFrame_identity)](/benchmarks/169.webp)

### ({true, false, true, false, true, false})

![({true, false, true, false, true, false})](/benchmarks/76.webp)

### ('', '', '', '', '', '', '')

![('', '', '', '', '', '', '')](/benchmarks/89.webp)

### ('aaaaaaaaaaaa')

![('aaaaaaaaaaaa')](/benchmarks/147.webp)

### (true, false, true, false, true, false, true)

![(true, false, true, false, true, false, true)](/benchmarks/72.webp)

### ({'', '', '', '', '', ''})

![({'', '', '', '', '', ''})](/benchmarks/88.webp)

### (CFrame.new(1, -2, 3))

![(CFrame_new(1, -2, 3))](/benchmarks/170.webp)

### (CFrame.new(-1, 2.5, -3.27))

![(CFrame_new(-1, 2_5, -3_27))](/benchmarks/182.webp)

### (Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5))

![(Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5))](/benchmarks/35.webp)

### (CFrame.new(1, 2, 3))

![(CFrame_new(1, 2, 3))](/benchmarks/165.webp)

### ({'a', 'a', 'a', 'a'})

![({'a', 'a', 'a', 'a'})](/benchmarks/56.webp)

### (CFrame.new())

![(CFrame_new())](/benchmarks/176.webp)

### ('a', 'a', 'a', 'a', 'a')

![('a', 'a', 'a', 'a', 'a')](/benchmarks/59.webp)

### ({Vector3.new(1, 2, 3)})

![({Vector3_new(1, 2, 3)})](/benchmarks/44.webp)

### (Vector2int16.new(-1, 3), Vector2int16.new(-1, 3), Vector2int16.new(-1, 3))

![(Vector2int16_new(-1, 3), Vector2int16_new(-1, 3), Vector2int16_new(-1, 3))](/benchmarks/108.webp)

### ('aaaaaaaaaaaaa')

![('aaaaaaaaaaaaa')](/benchmarks/157.webp)

### ({'', '', '', '', '', '', ''})

![({'', '', '', '', '', '', ''})](/benchmarks/91.webp)

### ('', '', '', '', '', '', '', '')

![('', '', '', '', '', '', '', '')](/benchmarks/94.webp)

### (true, false, true, false, true, false, true, false)

![(true, false, true, false, true, false, true, false)](/benchmarks/74.webp)

### ('aaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaa')](/benchmarks/122.webp)

### ({true, false, true, false, true, false, true})

![({true, false, true, false, true, false, true})](/benchmarks/73.webp)

### ({CFrame.identity})

![({CFrame_identity})](/benchmarks/183.webp)

### ({Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5)})

![({Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5)})](/benchmarks/34.webp)

### ({Vector2int16.new(-1, 3), Vector2int16.new(-1, 3), Vector2int16.new(-1, 3)})

![({Vector2int16_new(-1, 3), Vector2int16_new(-1, 3), Vector2int16_new(-1, 3)})](/benchmarks/110.webp)

### ('aaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaa')](/benchmarks/115.webp)

### ({'a', 'a', 'a', 'a', 'a'})

![({'a', 'a', 'a', 'a', 'a'})](/benchmarks/66.webp)

### (Vector2.new(1, 2), Vector2.new(1, 2))

![(Vector2_new(1, 2), Vector2_new(1, 2))](/benchmarks/26.webp)

### ('aaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaa')](/benchmarks/143.webp)

### (0, 0)

![(0, 0)](/benchmarks/5.webp)

### ('', '', '', '', '', '', '', '', '')

![('', '', '', '', '', '', '', '', '')](/benchmarks/93.webp)

### ({true, false, true, false, true, false, true, false})

![({true, false, true, false, true, false, true, false})](/benchmarks/82.webp)

### ({'', '', '', '', '', '', '', ''})

![({'', '', '', '', '', '', '', ''})](/benchmarks/97.webp)

### ('a', 'a', 'a', 'a', 'a', 'a')

![('a', 'a', 'a', 'a', 'a', 'a')](/benchmarks/55.webp)

### ('aaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaa')](/benchmarks/151.webp)

### (CFrame.fromEulerAnglesYXZ(1, -2, 3))

![(CFrame_fromEulerAnglesYXZ(1, -2, 3))](/benchmarks/174.webp)

### ({Vector2.new(1, 2), Vector2.new(1, 2)})

![({Vector2_new(1, 2), Vector2_new(1, 2)})](/benchmarks/27.webp)

### ({0, 0})

![({0, 0})](/benchmarks/20.webp)

### ({'', '', '', '', '', '', '', '', ''})

![({'', '', '', '', '', '', '', '', ''})](/benchmarks/85.webp)

### ({'a', 'a', 'a', 'a', 'a', 'a'})

![({'a', 'a', 'a', 'a', 'a', 'a'})](/benchmarks/63.webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3))](/benchmarks/163.webp)

### (CFrame.fromEulerAnglesYXZ(-1, 2.5, -3.27) + Vector3.new(-1, -2, -3))

![(CFrame_fromEulerAnglesYXZ(-1, 2_5, -3_27) + Vector3_new(-1, -2, -3))](/benchmarks/181.webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3))](/benchmarks/184.webp)

### (CFrame.fromEulerAnglesYXZ(1, -2, 3) + Vector3.new(-1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, -2, 3) + Vector3_new(-1, 2, 3))](/benchmarks/172.webp)

### (CFrame.fromEulerAnglesYXZ(-1, 2.5, -3.27))

![(CFrame_fromEulerAnglesYXZ(-1, 2_5, -3_27))](/benchmarks/177.webp)

### ('aaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaa')](/benchmarks/127.webp)

### ('aaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaa')](/benchmarks/132.webp)

### ('a', 'a', 'a', 'a', 'a', 'a', 'a')

![('a', 'a', 'a', 'a', 'a', 'a', 'a')](/benchmarks/53.webp)

### (Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5))

![(Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5))](/benchmarks/37.webp)

### ({CFrame.fromEulerAnglesYXZ(1, 2, 3)})

![({CFrame_fromEulerAnglesYXZ(1, 2, 3)})](/benchmarks/179.webp)

### ('aaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaa')](/benchmarks/138.webp)

### ({Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5)})

![({Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5)})](/benchmarks/33.webp)

### ({'a', 'a', 'a', 'a', 'a', 'a', 'a'})

![({'a', 'a', 'a', 'a', 'a', 'a', 'a'})](/benchmarks/64.webp)

### ('aaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaa')](/benchmarks/144.webp)

### ('a', 'a', 'a', 'a', 'a', 'a', 'a', 'a')

![('a', 'a', 'a', 'a', 'a', 'a', 'a', 'a')](/benchmarks/57.webp)

### ('aaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/152.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/124.webp)

### (Vector3.new(1, 2, 3), Vector3.new(1, 2, 3))

![(Vector3_new(1, 2, 3), Vector3_new(1, 2, 3))](/benchmarks/46.webp)

### ({'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a'})

![({'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a'})](/benchmarks/65.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/145.webp)

### (Vector2.new(1, 2), Vector2.new(1, 2), Vector2.new(1, 2))

![(Vector2_new(1, 2), Vector2_new(1, 2), Vector2_new(1, 2))](/benchmarks/30.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/135.webp)

### (0, 0, 0)

![(0, 0, 0)](/benchmarks/13.webp)

### (CFrame.new(), CFrame.new())

![(CFrame_new(), CFrame_new())](/benchmarks/167.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/129.webp)

### ({Vector3.new(1, 2, 3), Vector3.new(1, 2, 3)})

![({Vector3_new(1, 2, 3), Vector3_new(1, 2, 3)})](/benchmarks/50.webp)

### ({0, 0, 0})

![({0, 0, 0})](/benchmarks/15.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/136.webp)

### ({Vector2.new(1, 2), Vector2.new(1, 2), Vector2.new(1, 2)})

![({Vector2_new(1, 2), Vector2_new(1, 2), Vector2_new(1, 2)})](/benchmarks/32.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/149.webp)

### ({CFrame.identity, CFrame.identity})

![({CFrame_identity, CFrame_identity})](/benchmarks/173.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/153.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/159.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/139.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/141.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/130.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/112.webp)

### (0, 0, 0, 0)

![(0, 0, 0, 0)](/benchmarks/4.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/118.webp)

### ({0, 0, 0, 0})

![({0, 0, 0, 0})](/benchmarks/3.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/154.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/142.webp)

### (Vector3.new(1, 2, 3), Vector3.new(1, 2, 3), Vector3.new(1, 2, 3))

![(Vector3_new(1, 2, 3), Vector3_new(1, 2, 3), Vector3_new(1, 2, 3))](/benchmarks/43.webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3))](/benchmarks/168.webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3))](/benchmarks/171.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/123.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/150.webp)

### ({Vector3.new(1, 2, 3), Vector3.new(1, 2, 3), Vector3.new(1, 2, 3)})

![({Vector3_new(1, 2, 3), Vector3_new(1, 2, 3), Vector3_new(1, 2, 3)})](/benchmarks/52.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/148.webp)

### ({CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3)})

![({CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3)})](/benchmarks/180.webp)

### (CFrame.new(), CFrame.new(), CFrame.new())

![(CFrame_new(), CFrame_new(), CFrame_new())](/benchmarks/162.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/128.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/155.webp)

### ({CFrame.identity, CFrame.identity, CFrame.identity})

![({CFrame_identity, CFrame_identity, CFrame_identity})](/benchmarks/166.webp)

### (0, 0, 0, 0, 0)

![(0, 0, 0, 0, 0)](/benchmarks/10.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/137.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/114.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/121.webp)

### ({0, 0, 0, 0, 0})

![({0, 0, 0, 0, 0})](/benchmarks/19.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/125.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/116.webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/156.webp)

### (0, 0, 0, 0, 0, 0)

![(0, 0, 0, 0, 0, 0)](/benchmarks/8.webp)

### ({0, 0, 0, 0, 0, 0})

![({0, 0, 0, 0, 0, 0})](/benchmarks/2.webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3))](/benchmarks/178.webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3))](/benchmarks/164.webp)

### ({CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3)})

![({CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3)})](/benchmarks/175.webp)

### (0, 0, 0, 0, 0, 0, 0)

![(0, 0, 0, 0, 0, 0, 0)](/benchmarks/12.webp)

### ({0, 0, 0, 0, 0, 0, 0})

![({0, 0, 0, 0, 0, 0, 0})](/benchmarks/21.webp)

### (0, 0, 0, 0, 0, 0, 0, 0)

![(0, 0, 0, 0, 0, 0, 0, 0)](/benchmarks/7.webp)

### ({0, 0, 0, 0, 0, 0, 0, 0})

![({0, 0, 0, 0, 0, 0, 0, 0})](/benchmarks/16.webp)

### (0, 0, 0, 0, 0, 0, 0, 0, 0)

![(0, 0, 0, 0, 0, 0, 0, 0, 0)](/benchmarks/11.webp)

### ({0, 0, 0, 0, 0, 0, 0, 0, 0})

![({0, 0, 0, 0, 0, 0, 0, 0, 0})](/benchmarks/6.webp)

