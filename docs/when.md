---
sidebar_position: 3
---

# When To Serialize?

Strings are great for serializing data, but we need to know when to serialize. Certain kinds of data is cheaper to send over the network than others. Below is an eye-measured average of the incoming kB/s from the Networking window in studio after stabilization. The code is on the server and fires a remote with the Value every task.wait().

| Value | Average Bandwidth (KB/s) | Notes | Conclusions |
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

**Below are different benchmarks that verifies the above table with better accuracy.**

To generate a JSON file of the test below results you can download [this place file](/netbench.rbxl) and run it in studio. For the json file of this benchmark presented on this page you can download [this json file](/Data.json). Just be warned, it will take a few hours to complete. The results are measured using the Stats service's DataRecieveKbps property 2000 times every 1-3 frames once the recieve rate has stabilized. It waits for the recieve rate to plateau at 0.15kb/s before starting the test, then waits 10 seconds to allow the averaged Stats.DataReceiveKbps to plateau at the maximum value before starting the measurements. Then it appends the current Stats.DataReceiveKbps value to an array every 1-3 frames 2000 times. The process is repeated for all the different kinds of data, which takes a while.

## Results

### ()

![()](/benchmarks/().webp)

### ('')

![('')](/benchmarks/('').webp)

### (true)

![(true)](/benchmarks/(true).webp)

### (false)

![(false)](/benchmarks/(false).webp)

### ({})

![({})](/benchmarks/({}).webp)

### ('A')

![('A')](/benchmarks/('a').webp)

### (string.char(255))

![(string_char(255))](/benchmarks/(string_char(255)).webp)

### ('a')

![('a')](/benchmarks/('a').webp)

### (string.char(0))

![(string_char(0))](/benchmarks/(string_char(0)).webp)

### ({true})

![({true})](/benchmarks/({true}).webp)

### ('aa')

![('aa')](/benchmarks/('aa').webp)

### (true, false)

![(true, false)](/benchmarks/(true,_false).webp)

### ({''})

![({''})](/benchmarks/({''}).webp)

### ('', '')

![('', '')](/benchmarks/('',_'').webp)

### (Vector2int16.new(1, -3))

![(Vector2int16_new(1, -3))](/benchmarks/(vector2int16_new(1,_-3)).webp)

### (Vector2int16.new(-1, -3))

![(Vector2int16_new(-1, -3))](/benchmarks/(vector2int16_new(-1,_-3)).webp)

### (Vector2int16.new(-1, 3))

![(Vector2int16_new(-1, 3))](/benchmarks/(vector2int16_new(-1,_3)).webp)

### ('aaa')

![('aaa')](/benchmarks/('aaa').webp)

### (Vector2int16.new(1, 3))

![(Vector2int16_new(1, 3))](/benchmarks/(vector2int16_new(1,_3)).webp)

### (true, false, true)

![(true, false, true)](/benchmarks/(true,_false,_true).webp)

### ('aaaa')

![('aaaa')](/benchmarks/('aaaa').webp)

### ('', '', '')

![('', '', '')](/benchmarks/('',_'',_'').webp)

### ({'', ''})

![({'', ''})](/benchmarks/({'',_''}).webp)

### ({true, false})

![({true, false})](/benchmarks/({true,_false}).webp)

### ('a', 'a')

![('a', 'a')](/benchmarks/('a',_'a').webp)

### ({Vector2int16.new(-1, 3)})

![({Vector2int16_new(-1, 3)})](/benchmarks/({vector2int16_new(-1,_3)}).webp)

### (Vector3int16.new(1, 3, 5))

![(Vector3int16_new(1, 3, 5))](/benchmarks/(vector3int16_new(1,_3,_5)).webp)

### (Vector3int16.new(-1, 3, -5))

![(Vector3int16_new(-1, 3, -5))](/benchmarks/(vector3int16_new(-1,_3,_-5)).webp)

### (Vector3int16.new(1, -3, 5))

![(Vector3int16_new(1, -3, 5))](/benchmarks/(vector3int16_new(1,_-3,_5)).webp)

### (Vector3int16.new(-1, -3, -5))

![(Vector3int16_new(-1, -3, -5))](/benchmarks/(vector3int16_new(-1,_-3,_-5)).webp)

### ('aaaaa')

![('aaaaa')](/benchmarks/('aaaaa').webp)

### ({'a', 'a'})

![({'a', 'a'})](/benchmarks/({'a',_'a'}).webp)

### ('', '', '', '')

![('', '', '', '')](/benchmarks/('',_'',_'',_'').webp)

### (true, false, true, false)

![(true, false, true, false)](/benchmarks/(true,_false,_true,_false).webp)

### ('aaaaaa')

![('aaaaaa')](/benchmarks/('aaaaaa').webp)

### ({true, false, true})

![({true, false, true})](/benchmarks/({true,_false,_true}).webp)

### ({'', '', ''})

![({'', '', ''})](/benchmarks/({'',_'',_''}).webp)

### (Vector2.zero)

![(Vector2_zero)](/benchmarks/(vector2_zero).webp)

### (0)

![(0)](/benchmarks/(0).webp)

### (18375)

![(18375)](/benchmarks/(18375).webp)

### ({Vector3int16.new(-1, 3, -5)})

![({Vector3int16_new(-1, 3, -5)})](/benchmarks/({vector3int16_new(-1,_3,_-5)}).webp)

### (Vector2.new(-1, 2.5))

![(Vector2_new(-1, 2_5))](/benchmarks/(vector2_new(-1,_2_5)).webp)

### ('a', 'a', 'a')

![('a', 'a', 'a')](/benchmarks/('a',_'a',_'a').webp)

### (Vector2.new(-1, -2.73))

![(Vector2_new(-1, -2_73))](/benchmarks/(vector2_new(-1,_-2_73)).webp)

### ('aaaaaaa')

![('aaaaaaa')](/benchmarks/('aaaaaaa').webp)

### (-18375)

![(-18375)](/benchmarks/(-18375).webp)

### (Vector2.new(1, -2))

![(Vector2_new(1, -2))](/benchmarks/(vector2_new(1,_-2)).webp)

### (Vector2.one)

![(Vector2_one)](/benchmarks/(vector2_one).webp)

### (Vector2.new(1, 2))

![(Vector2_new(1, 2))](/benchmarks/(vector2_new(1,_2)).webp)

### (Vector2int16.new(-1, 3), Vector2int16.new(-1, 3))

![(Vector2int16_new(-1, 3), Vector2int16_new(-1, 3))](/benchmarks/(vector2int16_new(-1,_3),_vector2int16_new(-1,_3)).webp)

### ('aaaaaaaa')

![('aaaaaaaa')](/benchmarks/('aaaaaaaa').webp)

### ({true, false, true, false})

![({true, false, true, false})](/benchmarks/({true,_false,_true,_false}).webp)

### ({'', '', '', ''})

![({'', '', '', ''})](/benchmarks/({'',_'',_'',_''}).webp)

### ('', '', '', '', '')

![('', '', '', '', '')](/benchmarks/('',_'',_'',_'',_'').webp)

### (true, false, true, false, true)

![(true, false, true, false, true)](/benchmarks/(true,_false,_true,_false,_true).webp)

### ('aaaaaaaaa')

![('aaaaaaaaa')](/benchmarks/('aaaaaaaaa').webp)

### ({0})

![({0})](/benchmarks/({0}).webp)

### ({'a', 'a', 'a'})

![({'a', 'a', 'a'})](/benchmarks/({'a',_'a',_'a'}).webp)

### ({Vector2.new(1, 2)})

![({Vector2_new(1, 2)})](/benchmarks/({vector2_new(1,_2)}).webp)

### ({Vector2int16.new(-1, 3), Vector2int16.new(-1, 3)})

![({Vector2int16_new(-1, 3), Vector2int16_new(-1, 3)})](/benchmarks/({vector2int16_new(-1,_3),_vector2int16_new(-1,_3)}).webp)

### ('', '', '', '', '', '')

![('', '', '', '', '', '')](/benchmarks/('',_'',_'',_'',_'',_'').webp)

### ({'', '', '', '', ''})

![({'', '', '', '', ''})](/benchmarks/({'',_'',_'',_'',_''}).webp)

### ('aaaaaaaaaa')

![('aaaaaaaaaa')](/benchmarks/('aaaaaaaaaa').webp)

### ('a', 'a', 'a', 'a')

![('a', 'a', 'a', 'a')](/benchmarks/('a',_'a',_'a',_'a').webp)

### (true, false, true, false, true, false)

![(true, false, true, false, true, false)](/benchmarks/(true,_false,_true,_false,_true,_false).webp)

### ({true, false, true, false, true})

![({true, false, true, false, true})](/benchmarks/({true,_false,_true,_false,_true}).webp)

### (Vector3.one)

![(Vector3_one)](/benchmarks/(vector3_one).webp)

### (Vector3.zero)

![(Vector3_zero)](/benchmarks/(vector3_zero).webp)

### (Vector3.new(1, -2, 3))

![(Vector3_new(1, -2, 3))](/benchmarks/(vector3_new(1,_-2,_3)).webp)

### (Vector3.new(1, 2, 3))

![(Vector3_new(1, 2, 3))](/benchmarks/(vector3_new(1,_2,_3)).webp)

### (Vector3.new())

![(Vector3_new())](/benchmarks/(vector3_new()).webp)

### ('aaaaaaaaaaa')

![('aaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaa').webp)

### (Vector3.new(-1, 2.5, -3.27))

![(Vector3_new(-1, 2_5, -3_27))](/benchmarks/(vector3_new(-1,_2_5,_-3_27)).webp)

### (CFrame.identity)

![(CFrame_identity)](/benchmarks/(cframe_identity).webp)

### ({true, false, true, false, true, false})

![({true, false, true, false, true, false})](/benchmarks/({true,_false,_true,_false,_true,_false}).webp)

### ('', '', '', '', '', '', '')

![('', '', '', '', '', '', '')](/benchmarks/('',_'',_'',_'',_'',_'',_'').webp)

### ('aaaaaaaaaaaa')

![('aaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaa').webp)

### (true, false, true, false, true, false, true)

![(true, false, true, false, true, false, true)](/benchmarks/(true,_false,_true,_false,_true,_false,_true).webp)

### ({'', '', '', '', '', ''})

![({'', '', '', '', '', ''})](/benchmarks/({'',_'',_'',_'',_'',_''}).webp)

### (CFrame.new(1, -2, 3))

![(CFrame_new(1, -2, 3))](/benchmarks/(cframe_new(1,_-2,_3)).webp)

### (CFrame.new(-1, 2.5, -3.27))

![(CFrame_new(-1, 2_5, -3_27))](/benchmarks/(cframe_new(-1,_2_5,_-3_27)).webp)

### (Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5))

![(Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5))](/benchmarks/(vector3int16_new(-1,_3,_-5),_vector3int16_new(-1,_3,_-5)).webp)

### (CFrame.new(1, 2, 3))

![(CFrame_new(1, 2, 3))](/benchmarks/(cframe_new(1,_2,_3)).webp)

### ({'a', 'a', 'a', 'a'})

![({'a', 'a', 'a', 'a'})](/benchmarks/({'a',_'a',_'a',_'a'}).webp)

### (CFrame.new())

![(CFrame_new())](/benchmarks/(cframe_new()).webp)

### ('a', 'a', 'a', 'a', 'a')

![('a', 'a', 'a', 'a', 'a')](/benchmarks/('a',_'a',_'a',_'a',_'a').webp)

### ({Vector3.new(1, 2, 3)})

![({Vector3_new(1, 2, 3)})](/benchmarks/({vector3_new(1,_2,_3)}).webp)

### (Vector2int16.new(-1, 3), Vector2int16.new(-1, 3), Vector2int16.new(-1, 3))

![(Vector2int16_new(-1, 3), Vector2int16_new(-1, 3), Vector2int16_new(-1, 3))](/benchmarks/(vector2int16_new(-1,_3),_vector2int16_new(-1,_3),_vector2int16_new(-1,_3)).webp)

### ('aaaaaaaaaaaaa')

![('aaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaa').webp)

### ({'', '', '', '', '', '', ''})

![({'', '', '', '', '', '', ''})](/benchmarks/({'',_'',_'',_'',_'',_'',_''}).webp)

### ('', '', '', '', '', '', '', '')

![('', '', '', '', '', '', '', '')](/benchmarks/('',_'',_'',_'',_'',_'',_'',_'').webp)

### (true, false, true, false, true, false, true, false)

![(true, false, true, false, true, false, true, false)](/benchmarks/(true,_false,_true,_false,_true,_false,_true,_false).webp)

### ('aaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaa').webp)

### ({true, false, true, false, true, false, true})

![({true, false, true, false, true, false, true})](/benchmarks/({true,_false,_true,_false,_true,_false,_true}).webp)

### ({CFrame.identity})

![({CFrame_identity})](/benchmarks/({cframe_identity}).webp)

### ({Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5)})

![({Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5)})](/benchmarks/({vector3int16_new(-1,_3,_-5),_vector3int16_new(-1,_3,_-5)}).webp)

### ({Vector2int16.new(-1, 3), Vector2int16.new(-1, 3), Vector2int16.new(-1, 3)})

![({Vector2int16_new(-1, 3), Vector2int16_new(-1, 3), Vector2int16_new(-1, 3)})](/benchmarks/({vector2int16_new(-1,_3),_vector2int16_new(-1,_3),_vector2int16_new(-1,_3)}).webp)

### ('aaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaa').webp)

### ({'a', 'a', 'a', 'a', 'a'})

![({'a', 'a', 'a', 'a', 'a'})](/benchmarks/({'a',_'a',_'a',_'a',_'a'}).webp)

### (Vector2.new(1, 2), Vector2.new(1, 2))

![(Vector2_new(1, 2), Vector2_new(1, 2))](/benchmarks/(vector2_new(1,_2),_vector2_new(1,_2)).webp)

### ('aaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaa').webp)

### (0, 0)

![(0, 0)](/benchmarks/(0,_0).webp)

### ('', '', '', '', '', '', '', '', '')

![('', '', '', '', '', '', '', '', '')](/benchmarks/('',_'',_'',_'',_'',_'',_'',_'',_'').webp)

### ({true, false, true, false, true, false, true, false})

![({true, false, true, false, true, false, true, false})](/benchmarks/({true,_false,_true,_false,_true,_false,_true,_false}).webp)

### ({'', '', '', '', '', '', '', ''})

![({'', '', '', '', '', '', '', ''})](/benchmarks/({'',_'',_'',_'',_'',_'',_'',_''}).webp)

### ('a', 'a', 'a', 'a', 'a', 'a')

![('a', 'a', 'a', 'a', 'a', 'a')](/benchmarks/('a',_'a',_'a',_'a',_'a',_'a').webp)

### ('aaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaa').webp)

### (CFrame.fromEulerAnglesYXZ(1, -2, 3))

![(CFrame_fromEulerAnglesYXZ(1, -2, 3))](/benchmarks/(cframe_fromeuleranglesyxz(1,_-2,_3)).webp)

### ({Vector2.new(1, 2), Vector2.new(1, 2)})

![({Vector2_new(1, 2), Vector2_new(1, 2)})](/benchmarks/({vector2_new(1,_2),_vector2_new(1,_2)}).webp)

### ({0, 0})

![({0, 0})](/benchmarks/({0,_0}).webp)

### ({'', '', '', '', '', '', '', '', ''})

![({'', '', '', '', '', '', '', '', ''})](/benchmarks/({'',_'',_'',_'',_'',_'',_'',_'',_''}).webp)

### ({'a', 'a', 'a', 'a', 'a', 'a'})

![({'a', 'a', 'a', 'a', 'a', 'a'})](/benchmarks/({'a',_'a',_'a',_'a',_'a',_'a'}).webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3))](/benchmarks/(cframe_fromeuleranglesyxz(1,_2,_3)_+_vector3_new(1,_2,_3)).webp)

### (CFrame.fromEulerAnglesYXZ(-1, 2.5, -3.27) + Vector3.new(-1, -2, -3))

![(CFrame_fromEulerAnglesYXZ(-1, 2_5, -3_27) + Vector3_new(-1, -2, -3))](/benchmarks/(cframe_fromeuleranglesyxz(-1,_2_5,_-3_27)_+_vector3_new(-1,_-2,_-3)).webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3))](/benchmarks/(cframe_fromeuleranglesyxz(1,_2,_3)).webp)

### (CFrame.fromEulerAnglesYXZ(1, -2, 3) + Vector3.new(-1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, -2, 3) + Vector3_new(-1, 2, 3))](/benchmarks/(cframe_fromeuleranglesyxz(1,_-2,_3)_+_vector3_new(-1,_2,_3)).webp)

### (CFrame.fromEulerAnglesYXZ(-1, 2.5, -3.27))

![(CFrame_fromEulerAnglesYXZ(-1, 2_5, -3_27))](/benchmarks/(cframe_fromeuleranglesyxz(-1,_2_5,_-3_27)).webp)

### ('aaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaa').webp)

### ('a', 'a', 'a', 'a', 'a', 'a', 'a')

![('a', 'a', 'a', 'a', 'a', 'a', 'a')](/benchmarks/('a',_'a',_'a',_'a',_'a',_'a',_'a').webp)

### (Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5))

![(Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5))](/benchmarks/(vector3int16_new(-1,_3,_-5),_vector3int16_new(-1,_3,_-5),_vector3int16_new(-1,_3,_-5)).webp)

### ({CFrame.fromEulerAnglesYXZ(1, 2, 3)})

![({CFrame_fromEulerAnglesYXZ(1, 2, 3)})](/benchmarks/({cframe_fromeuleranglesyxz(1,_2,_3)}).webp)

### ('aaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaa').webp)

### ({Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5), Vector3int16.new(-1, 3, -5)})

![({Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5), Vector3int16_new(-1, 3, -5)})](/benchmarks/({vector3int16_new(-1,_3,_-5),_vector3int16_new(-1,_3,_-5),_vector3int16_new(-1,_3,_-5)}).webp)

### ({'a', 'a', 'a', 'a', 'a', 'a', 'a'})

![({'a', 'a', 'a', 'a', 'a', 'a', 'a'})](/benchmarks/({'a',_'a',_'a',_'a',_'a',_'a',_'a'}).webp)

### ('aaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaa').webp)

### ('a', 'a', 'a', 'a', 'a', 'a', 'a', 'a')

![('a', 'a', 'a', 'a', 'a', 'a', 'a', 'a')](/benchmarks/('a',_'a',_'a',_'a',_'a',_'a',_'a',_'a').webp)

### ('aaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaa').webp)

### (Vector3.new(1, 2, 3), Vector3.new(1, 2, 3))

![(Vector3_new(1, 2, 3), Vector3_new(1, 2, 3))](/benchmarks/(vector3_new(1,_2,_3),_vector3_new(1,_2,_3)).webp)

### ({'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a'})

![({'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a'})](/benchmarks/({'a',_'a',_'a',_'a',_'a',_'a',_'a',_'a'}).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaa').webp)

### (Vector2.new(1, 2), Vector2.new(1, 2), Vector2.new(1, 2))

![(Vector2_new(1, 2), Vector2_new(1, 2), Vector2_new(1, 2))](/benchmarks/(vector2_new(1,_2),_vector2_new(1,_2),_vector2_new(1,_2)).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### (0, 0, 0)

![(0, 0, 0)](/benchmarks/(0,_0,_0).webp)

### (CFrame.new(), CFrame.new())

![(CFrame_new(), CFrame_new())](/benchmarks/(cframe_new(),_cframe_new()).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ({Vector3.new(1, 2, 3), Vector3.new(1, 2, 3)})

![({Vector3_new(1, 2, 3), Vector3_new(1, 2, 3)})](/benchmarks/({vector3_new(1,_2,_3),_vector3_new(1,_2,_3)}).webp)

### ({0, 0, 0})

![({0, 0, 0})](/benchmarks/({0,_0,_0}).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ({Vector2.new(1, 2), Vector2.new(1, 2), Vector2.new(1, 2)})

![({Vector2_new(1, 2), Vector2_new(1, 2), Vector2_new(1, 2)})](/benchmarks/({vector2_new(1,_2),_vector2_new(1,_2),_vector2_new(1,_2)}).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ({CFrame.identity, CFrame.identity})

![({CFrame_identity, CFrame_identity})](/benchmarks/({cframe_identity,_cframe_identity}).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### (0, 0, 0, 0)

![(0, 0, 0, 0)](/benchmarks/(0,_0,_0,_0).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ({0, 0, 0, 0})

![({0, 0, 0, 0})](/benchmarks/({0,_0,_0,_0}).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### (Vector3.new(1, 2, 3), Vector3.new(1, 2, 3), Vector3.new(1, 2, 3))

![(Vector3_new(1, 2, 3), Vector3_new(1, 2, 3), Vector3_new(1, 2, 3))](/benchmarks/(vector3_new(1,_2,_3),_vector3_new(1,_2,_3),_vector3_new(1,_2,_3)).webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3))](/benchmarks/(cframe_fromeuleranglesyxz(1,_2,_3),_cframe_fromeuleranglesyxz(1,_2,_3)).webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3))](/benchmarks/(cframe_fromeuleranglesyxz(1,_2,_3)_+_vector3_new(1,_2,_3),_cframe_fromeuleranglesyxz(1,_2,_3)_+_vector3_new(1,_2,_3)).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ({Vector3.new(1, 2, 3), Vector3.new(1, 2, 3), Vector3.new(1, 2, 3)})

![({Vector3_new(1, 2, 3), Vector3_new(1, 2, 3), Vector3_new(1, 2, 3)})](/benchmarks/({vector3_new(1,_2,_3),_vector3_new(1,_2,_3),_vector3_new(1,_2,_3)}).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ({CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3)})

![({CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3)})](/benchmarks/({cframe_fromeuleranglesyxz(1,_2,_3),_cframe_fromeuleranglesyxz(1,_2,_3)}).webp)

### (CFrame.new(), CFrame.new(), CFrame.new())

![(CFrame_new(), CFrame_new(), CFrame_new())](/benchmarks/(cframe_new(),_cframe_new(),_cframe_new()).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ({CFrame.identity, CFrame.identity, CFrame.identity})

![({CFrame_identity, CFrame_identity, CFrame_identity})](/benchmarks/({cframe_identity,_cframe_identity,_cframe_identity}).webp)

### (0, 0, 0, 0, 0)

![(0, 0, 0, 0, 0)](/benchmarks/(0,_0,_0,_0,_0).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ({0, 0, 0, 0, 0})

![({0, 0, 0, 0, 0})](/benchmarks/({0,_0,_0,_0,_0}).webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')

![('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')](/benchmarks/('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').webp)

### (0, 0, 0, 0, 0, 0)

![(0, 0, 0, 0, 0, 0)](/benchmarks/(0,_0,_0,_0,_0,_0).webp)

### ({0, 0, 0, 0, 0, 0})

![({0, 0, 0, 0, 0, 0})](/benchmarks/({0,_0,_0,_0,_0,_0}).webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3))](/benchmarks/(cframe_fromeuleranglesyxz(1,_2,_3),_cframe_fromeuleranglesyxz(1,_2,_3),_cframe_fromeuleranglesyxz(1,_2,_3)).webp)

### (CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3) + Vector3.new(1, 2, 3))

![(CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3) + Vector3_new(1, 2, 3))](/benchmarks/(cframe_fromeuleranglesyxz(1,_2,_3)_+_vector3_new(1,_2,_3),_cframe_fromeuleranglesyxz(1,_2,_3)_+_vector3_new(1,_2,_3),_cframe_fromeuleranglesyxz(1,_2,_3)_+_vector3_new(1,_2,_3)).webp)

### ({CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3), CFrame.fromEulerAnglesYXZ(1, 2, 3)})

![({CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3), CFrame_fromEulerAnglesYXZ(1, 2, 3)})](/benchmarks/({cframe_fromeuleranglesyxz(1,_2,_3),_cframe_fromeuleranglesyxz(1,_2,_3),_cframe_fromeuleranglesyxz(1,_2,_3)}).webp)

### (0, 0, 0, 0, 0, 0, 0)

![(0, 0, 0, 0, 0, 0, 0)](/benchmarks/(0,_0,_0,_0,_0,_0,_0).webp)

### ({0, 0, 0, 0, 0, 0, 0})

![({0, 0, 0, 0, 0, 0, 0})](/benchmarks/({0,_0,_0,_0,_0,_0,_0}).webp)

### (0, 0, 0, 0, 0, 0, 0, 0)

![(0, 0, 0, 0, 0, 0, 0, 0)](/benchmarks/(0,_0,_0,_0,_0,_0,_0,_0).webp)

### ({0, 0, 0, 0, 0, 0, 0, 0})

![({0, 0, 0, 0, 0, 0, 0, 0})](/benchmarks/({0,_0,_0,_0,_0,_0,_0,_0}).webp)

### (0, 0, 0, 0, 0, 0, 0, 0, 0)

![(0, 0, 0, 0, 0, 0, 0, 0, 0)](/benchmarks/(0,_0,_0,_0,_0,_0,_0,_0,_0).webp)

### ({0, 0, 0, 0, 0, 0, 0, 0, 0})

![({0, 0, 0, 0, 0, 0, 0, 0, 0})](/benchmarks/({0,_0,_0,_0,_0,_0,_0,_0,_0}).webp)

