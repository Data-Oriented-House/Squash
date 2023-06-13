"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[6683],{3905:(e,t,a)=>{a.d(t,{Zo:()=>m,kt:()=>h});var n=a(67294);function r(e,t,a){return t in e?Object.defineProperty(e,t,{value:a,enumerable:!0,configurable:!0,writable:!0}):e[t]=a,e}function l(e,t){var a=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),a.push.apply(a,n)}return a}function s(e){for(var t=1;t<arguments.length;t++){var a=null!=arguments[t]?arguments[t]:{};t%2?l(Object(a),!0).forEach((function(t){r(e,t,a[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(a)):l(Object(a)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(a,t))}))}return e}function i(e,t){if(null==e)return{};var a,n,r=function(e,t){if(null==e)return{};var a,n,r={},l=Object.keys(e);for(n=0;n<l.length;n++)a=l[n],t.indexOf(a)>=0||(r[a]=e[a]);return r}(e,t);if(Object.getOwnPropertySymbols){var l=Object.getOwnPropertySymbols(e);for(n=0;n<l.length;n++)a=l[n],t.indexOf(a)>=0||Object.prototype.propertyIsEnumerable.call(e,a)&&(r[a]=e[a])}return r}var o=n.createContext({}),p=function(e){var t=n.useContext(o),a=t;return e&&(a="function"==typeof e?e(t):s(s({},t),e)),a},m=function(e){var t=p(e.components);return n.createElement(o.Provider,{value:t},e.children)},u="mdxType",d={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},g=n.forwardRef((function(e,t){var a=e.components,r=e.mdxType,l=e.originalType,o=e.parentName,m=i(e,["components","mdxType","originalType","parentName"]),u=p(a),g=r,h=u["".concat(o,".").concat(g)]||u[g]||d[g]||l;return a?n.createElement(h,s(s({ref:t},m),{},{components:a})):n.createElement(h,s({ref:t},m))}));function h(e,t){var a=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var l=a.length,s=new Array(l);s[0]=g;var i={};for(var o in t)hasOwnProperty.call(t,o)&&(i[o]=t[o]);i.originalType=e,i[u]="string"==typeof e?e:r,s[1]=i;for(var p=2;p<l;p++)s[p]=a[p];return n.createElement.apply(null,s)}return n.createElement.apply(null,a)}g.displayName="MDXCreateElement"},38725:(e,t,a)=>{a.r(t),a.d(t,{assets:()=>o,contentTitle:()=>s,default:()=>d,frontMatter:()=>l,metadata:()=>i,toc:()=>p});var n=a(87462),r=(a(67294),a(3905));const l={sidebar_position:3},s="How To Serialize?",i={unversionedId:"how",id:"how",title:"How To Serialize?",description:"Every character in a string can represent 256 possible values, since there are 256 characters in extended ASCII or UTF-8. This is equivalent to 8 bits, or 1 byte. Therefore, we can represent 256^2 = 65536 possible values with 2 characters, 256^3 = 16777216 possible values with 3 characters, and so on. There are many ways to interpret these bytes depending on context. Knowing how to interpret these bytes is the key to serialization.",source:"@site/docs/how.md",sourceDirName:".",slug:"/how",permalink:"/Squash/docs/how",draft:!1,editUrl:"https://github.com/Data-Oriented-House/Squash/edit/main/docs/how.md",tags:[],version:"current",sidebarPosition:3,frontMatter:{sidebar_position:3},sidebar:"defaultSidebar",previous:{title:"Why Squash?",permalink:"/Squash/docs/why"}},o={},p=[{value:"Booleans",id:"booleans",level:2},{value:"Numbers",id:"numbers",level:2},{value:"Unsigned Integers",id:"unsigned-integers",level:3},{value:"Signed Integers",id:"signed-integers",level:3},{value:"Floating Point",id:"floating-point",level:3},{value:"Strings",id:"strings",level:2}],m={toc:p},u="wrapper";function d(e){let{components:t,...l}=e;return(0,r.kt)(u,(0,n.Z)({},m,l,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"how-to-serialize"},"How To Serialize?"),(0,r.kt)("p",null,"Every character in a string can represent 256 possible values, since there are 256 characters in extended ASCII or UTF-8. This is equivalent to 8 bits, or 1 byte. Therefore, we can represent 256^2 = 65536 possible values with 2 characters, 256^3 = 16777216 possible values with 3 characters, and so on. There are many ways to interpret these bytes depending on context. Knowing how to interpret these bytes is the key to serialization."),(0,r.kt)("h2",{id:"booleans"},"Booleans"),(0,r.kt)("p",null,"In Luau, the ",(0,r.kt)("inlineCode",{parentName:"p"},"boolean")," type is 1 byte large, but only 1 bit is actually necessary to store the contents of a boolean. This means we can actually serialize not just 1, but 8 booleans in a single byte. This is a common strategy called ",(0,r.kt)("a",{parentName:"p",href:"https://en.wikipedia.org/wiki/Mask_(computing)"},(0,r.kt)("em",{parentName:"a"},"bit masking")),"."),(0,r.kt)("table",null,(0,r.kt)("thead",{parentName:"table"},(0,r.kt)("tr",{parentName:"thead"},(0,r.kt)("th",{parentName:"tr",align:null},"Happy"),(0,r.kt)("th",{parentName:"tr",align:null},"Confused"),(0,r.kt)("th",{parentName:"tr",align:null},"Irritated"),(0,r.kt)("th",{parentName:"tr",align:null},"Concerned"),(0,r.kt)("th",{parentName:"tr",align:null},"Angry"),(0,r.kt)("th",{parentName:"tr",align:null},"Humber"),(0,r.kt)("th",{parentName:"tr",align:null},"Dazed"),(0,r.kt)("th",{parentName:"tr",align:null},"Nage"))),(0,r.kt)("tbody",{parentName:"table"},(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"1"),(0,r.kt)("td",{parentName:"tr",align:null},"1"),(0,r.kt)("td",{parentName:"tr",align:null},"0"),(0,r.kt)("td",{parentName:"tr",align:null},"1"),(0,r.kt)("td",{parentName:"tr",align:null},"0"),(0,r.kt)("td",{parentName:"tr",align:null},"1"),(0,r.kt)("td",{parentName:"tr",align:null},"1"),(0,r.kt)("td",{parentName:"tr",align:null},"0")))),(0,r.kt)("p",null,"All of this information fits inside a single character! We can use this to serialize 8 booleans in a single byte. This is called a ",(0,r.kt)("em",{parentName:"p"},"byte mask"),"."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.boolean.ser(true)\nprint(y) -- \u263a\nprint(Squash.boolean.des(y)) -- true, false, false, false, false, false, false, false\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.boolean.ser(true, false, true, false, true, true, false, true)\nprint(y) -- \u2561\nprint(Squash.boolean.des(y)) -- true, false, true, false, true, true, false, true\n")),(0,r.kt)("h2",{id:"numbers"},"Numbers"),(0,r.kt)("p",null,"In Luau, the ",(0,r.kt)("inlineCode",{parentName:"p"},"number")," type is 8 bytes large, but only 52 of the bits are dedicated to storing the contents of the number. This means there is no need to serialize more than 8 bytes for any kind of number."),(0,r.kt)("h3",{id:"unsigned-integers"},"Unsigned Integers"),(0,r.kt)("p",null,"Unsigned integers are whole numbers that can be serialized using 1 to 8 bytes."),(0,r.kt)("p",null,(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},"N = { 0, 1, 2, 3, 4, 5, . . . }"))),(0,r.kt)("p",null,"They may only be positive and can represent all possible permutations of their bits. These are the easiest to wrap our heads around and manipulate. They are often used to implement ",(0,r.kt)("a",{parentName:"p",href:"https://en.wikipedia.org/wiki/Fixed-point_arithmetic"},"Fixed Point")," numbers by multiplying by some scale factor and shifting by some offset, then doing the reverse when deserializing."),(0,r.kt)("table",null,(0,r.kt)("thead",{parentName:"table"},(0,r.kt)("tr",{parentName:"thead"},(0,r.kt)("th",{parentName:"tr",align:null},"Bytes"),(0,r.kt)("th",{parentName:"tr",align:null},"Range"),(0,r.kt)("th",{parentName:"tr",align:null},"Min"),(0,r.kt)("th",{parentName:"tr",align:null},"Max"))),(0,r.kt)("tbody",{parentName:"table"},(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"1"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},"{ 0, 1, 2, 3, . . . , 253, 254, 255 }")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"0"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"255")))),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"2"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},"{ 0, 1, 2, 3, . . . , 65,534, 65,535 }")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"0"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"65,535")))),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"3"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},"{ 0, 1, 2, 3, . . . , 16,777,214, 16,777,215 }")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"0"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"16,777,215")))),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},". . ."),(0,r.kt)("td",{parentName:"tr",align:null},". . ."),(0,r.kt)("td",{parentName:"tr",align:null},". . ."),(0,r.kt)("td",{parentName:"tr",align:null},". . .")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"n"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},"{ 0, 1, 2, 3, . . . , 2^(8n) - 2, 2^(8n) - 1 }")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"0"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"2^(8n) - 1")))))),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.uint.ser(243, 1)\nprint(y) -- \u2264\nprint(Squash.uint.des(y, 1)) -- 243\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.uint.ser(-13, 1)\nprint(y) -- \u2264\nprint(Squash.uint.des(y, 1)) -- 243\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.uint.ser(7365, 2)\nprint(y) -- \u253c\u221f\nprint(Squash.uint.des(y, 2)) -- 7365\n")),(0,r.kt)("h3",{id:"signed-integers"},"Signed Integers"),(0,r.kt)("p",null,"Signed Integers are Integers that can be serialized with 1 through 8 bytes:"),(0,r.kt)("p",null,(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},"Z = { ..., -2, -1, 0, 1, 2, 3, ... }"))),(0,r.kt)("p",null,"They use ",(0,r.kt)("a",{parentName:"p",href:"https://en.wikipedia.org/wiki/Two%27s_complement"},"2's Compliment")," to represent negative numbers. The first bit is called the ",(0,r.kt)("em",{parentName:"p"},"sign bit")," and the rest of the bits are called the ",(0,r.kt)("em",{parentName:"p"},"magnitude bits"),". The sign bit is 0 for positive numbers and 1 for negative numbers. This implies the range of signed integers is one power of two smaller than the range of unsigned integers with the same number of bits, because the sign bit is not included in the magnitude bits."),(0,r.kt)("table",null,(0,r.kt)("thead",{parentName:"table"},(0,r.kt)("tr",{parentName:"thead"},(0,r.kt)("th",{parentName:"tr",align:null},"Bytes"),(0,r.kt)("th",{parentName:"tr",align:null},"Range"),(0,r.kt)("th",{parentName:"tr",align:null},"Min"),(0,r.kt)("th",{parentName:"tr",align:null},"Max"))),(0,r.kt)("tbody",{parentName:"table"},(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"1"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},"{ -128, -127, . . . , 126, 127 }")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"-128"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"127")))),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"2"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},"{ -32,768, -32,767, . . . , 32,766, 32,767 }")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"-32,768"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"32,767")))),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"3"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},"{ -8,388,608, -8,388,607, . . . , 8,388,606, 8,388,607 }")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"-8,388,608"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"8,388,607")))),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},". . ."),(0,r.kt)("td",{parentName:"tr",align:null},". . ."),(0,r.kt)("td",{parentName:"tr",align:null},". . ."),(0,r.kt)("td",{parentName:"tr",align:null},". . .")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"n"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},"{ -2^(8n - 1), -2^(8n - 1) + 1, . . . , 2^(8n - 1) - 2, 2^(8n - 1) - 1 }")),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"-2^(8n - 1)"))),(0,r.kt)("td",{parentName:"tr",align:null},(0,r.kt)("strong",{parentName:"td"},(0,r.kt)("em",{parentName:"strong"},"2^(8n - 1) - 1")))))),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.int.ser(127, 1)\nprint(y) -- cannot display A\nprint(Squash.int.des(y, 1)) -- 127\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.int.ser(-127, 1)\nprint(y) -- cannot display B\nprint(Squash.int.des(y, 1)) -- -127\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.int.ser(128, 1)\nprint(y) -- cannot display C\nprint(Squash.int.des(y, 1)) -- -128\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.int.ser(-128, 1)\nprint(y) -- cannot display C\nprint(Squash.int.des(y, 1)) -- -128\n")),(0,r.kt)("h3",{id:"floating-point"},"Floating Point"),(0,r.kt)("p",null,"Floating Point Numbers are Real Numbers that can be serialized with either 4 or 8 bytes:"),(0,r.kt)("p",null,(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},"R = { ..., -2.0, ..., -1.0, ..., 0.0, ..., 1.0, ..., 2.0, ... }"))),(0,r.kt)("p",null,"With 4 bytes (called a ",(0,r.kt)("inlineCode",{parentName:"p"},"float"),"), the possible values that can be represented are a bit more complicated. The first bit is used to represent the sign of the number, the next 8 bits are used to represent the exponent, and the last 23 bits are used to represent the mantissa."),(0,r.kt)("p",null,(0,r.kt)("img",{alt:"Floating Point",src:a(39977).Z,width:"1920",height:"323"})),(0,r.kt)("p",null,"The formula for calculating the value of a ",(0,r.kt)("inlineCode",{parentName:"p"},"float")," from its sign, exponent, and mantissa can be found at ",(0,r.kt)("a",{parentName:"p",href:"https://en.wikipedia.org/wiki/Single-precision_floating-point_format"},"this wikipedia article"),"."),(0,r.kt)("p",null,"With 8 bytes (called a ",(0,r.kt)("inlineCode",{parentName:"p"},"double"),"). The first bit is used to represent the sign of the number, the next 11 bits are used to represent the exponent, and the last 52 bits are used to represent the mantissa."),(0,r.kt)("p",null,(0,r.kt)("img",{alt:"Double Precision Floating Point",src:a(99246).Z,width:"1920",height:"388"})),(0,r.kt)("p",null,"The formula for calculating the value of a ",(0,r.kt)("inlineCode",{parentName:"p"},"double")," from its sign, exponent, and mantissa can be found at ",(0,r.kt)("a",{parentName:"p",href:"https://en.wikipedia.org/wiki/Double-precision_floating-point_format"},"this wikipedia article"),"."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.float.ser(174302.923957475339573, 4)\nprint(y) -- \u25577*H\nprint(Squash.float.des(y, 4)) -- 174302.921875\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local y = Squash.float.ser(-17534840302.923957475339573, 8)\nprint(y) -- "\u2593\u2557\u2556\xedT\u25ba\u252c\nprint(Squash.float.des(y, 8)) -- -17534840302.923958\n')),(0,r.kt)("h2",{id:"strings"},"Strings"),(0,r.kt)("p",null,"Strings are a bit more complicated than numbers. There are many ways to compress serialized strings, a lossless approach is to treat the string itself as a number and convert the number into a higher base, or radix. This is called ",(0,r.kt)("a",{parentName:"p",href:"https://en.wikipedia.org/wiki/Radix"},"base conversion"),". Strings come in many different ",(0,r.kt)("em",{parentName:"p"},"flavors")," though, so we need to know how to serialize each ",(0,r.kt)("em",{parentName:"p"},"flavor"),". Each string is composed of a sequence of certain characters. The set of those certain characters is called that string's smallest ",(0,r.kt)("strong",{parentName:"p"},"Alphabet"),". For example the string ",(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},'"Hello, World!"'))," has the alphabet ",(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},'" !,HWdelorw"')),". We can assign a number to each character in the alphabet like its position in the string. With our example:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"{\n    [' '] = 1, ['!'] = 2, [','] = 3, ['H'] = 4, ['W'] = 5,\n    ['d'] = 6, ['e'] = 7, ['l'] = 8, ['o'] = 9, ['r'] = 10,\n    ['w'] = 11,\n}\n")),(0,r.kt)("p",null,"This allows us to now calculate a numerical value for each string using ",(0,r.kt)("a",{parentName:"p",href:"https://en.wikipedia.org/wiki/Positional_notation"},"Positional Notation"),". The alphabet above has a radix of 11, so we can convert the string into a number with base 11. We can then use the base conversion formula, modified to work with strings, to convert the number with a radix 11 alphabet into a number with a radix 256 alphabet such as extended ASCII or UTF-8. To prevent our numbers from being shortened due to leading 0's, we have to use an extra character in our alphabet in the 0's place that we never use, such as the \\0 character, making our radix 12. Long story short, you can fit ",(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},"log12(256) = 2.23"))," characters from the original string into a single character in the new string. This proccess is invertible and lossless, so we can convert the serialized string back into the original string when we are ready. To play with this concept for arbitrary alphabets, you can visit ",(0,r.kt)("a",{parentName:"p",href:"https://convert.zamicol.com/"},"zamicol's base converter")," which supports these exact operations and comes with many pre-defined alphabets."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local x = 'Hello, world!'\n\nlocal alphabet = Squash.string.alphabet(x)\nprint(alphabet) -- ' !,Hdelorw'\n\nlocal y = Squash.string.ser(x, alphabet)\nprint(y) --[[    <-- There is a newline character here\n'\ufffd\ufffdC\ufffd]]\n\nprint(Squash.string.des(y, alphabet)) -- 'Hello, world!'\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.string.ser('great sword', Squash.lower .. ' ')\nprint(y) -- \b\f\ufffd\ufffdL\ufffd,\n\nprint(Squash.string.des(y, Squash.lower .. '  ')) -- 'great sword'\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.string.convert('lowercase', Squash.lower, Squash.upper)\nprint(y) -- 'LOWERCASE'\n\nprint(Squash.string.convert(y, Squash.upper, Squash.lower)) -- 'lowercase'\n")),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local y = Squash.string.convert('1936', Squash.decimal, Squash.binary)\nprint(y) -- '11110010000'\nprint(Squash.string.convert(y, Squash.binary, Squash.decimal)) -- '1936'\n")))}d.isMDXComponent=!0},39977:(e,t,a)=>{a.d(t,{Z:()=>n});const n=a.p+"assets/images/floatingpoint-511015af5d8758076aca99bdfbae89cb.png"},99246:(e,t,a)=>{a.d(t,{Z:()=>n});const n=a.p+"assets/images/floatingpointdouble-6bb419d0e13b26edd712bd7c78838243.png"}}]);