"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[671],{3905:(e,t,r)=>{r.d(t,{Zo:()=>c,kt:()=>m});var n=r(67294);function a(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function o(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,n)}return r}function i(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?o(Object(r),!0).forEach((function(t){a(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):o(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function s(e,t){if(null==e)return{};var r,n,a=function(e,t){if(null==e)return{};var r,n,a={},o=Object.keys(e);for(n=0;n<o.length;n++)r=o[n],t.indexOf(r)>=0||(a[r]=e[r]);return a}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(n=0;n<o.length;n++)r=o[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(a[r]=e[r])}return a}var l=n.createContext({}),d=function(e){var t=n.useContext(l),r=t;return e&&(r="function"==typeof e?e(t):i(i({},t),e)),r},c=function(e){var t=d(e.components);return n.createElement(l.Provider,{value:t},e.children)},p="mdxType",u={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},h=n.forwardRef((function(e,t){var r=e.components,a=e.mdxType,o=e.originalType,l=e.parentName,c=s(e,["components","mdxType","originalType","parentName"]),p=d(r),h=a,m=p["".concat(l,".").concat(h)]||p[h]||u[h]||o;return r?n.createElement(m,i(i({ref:t},c),{},{components:r})):n.createElement(m,i({ref:t},c))}));function m(e,t){var r=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var o=r.length,i=new Array(o);i[0]=h;var s={};for(var l in t)hasOwnProperty.call(t,l)&&(s[l]=t[l]);s.originalType=e,s[p]="string"==typeof e?e:a,i[1]=s;for(var d=2;d<o;d++)i[d]=r[d];return n.createElement.apply(null,i)}return n.createElement.apply(null,r)}h.displayName="MDXCreateElement"},59881:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>l,contentTitle:()=>i,default:()=>u,frontMatter:()=>o,metadata:()=>s,toc:()=>d});var n=r(87462),a=(r(67294),r(3905));const o={sidebar_position:1},i="What Is SerDes?",s={unversionedId:"intro",id:"intro",title:"What Is SerDes?",description:"Serdes is a common abbreviation used for Serialization Deserialization.",source:"@site/docs/intro.md",sourceDirName:".",slug:"/intro",permalink:"/Squash/docs/intro",draft:!1,editUrl:"https://github.com/Data-Oriented-House/Squash/edit/main/docs/intro.md",tags:[],version:"current",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"defaultSidebar",next:{title:"Why Squash?",permalink:"/Squash/docs/why"}},l={},d=[{value:"Why SerDes?",id:"why-serdes",level:2},{value:"Minimizing Latency",id:"minimizing-latency",level:3},{value:"Saving Space",id:"saving-space",level:3},{value:"When SerDes?",id:"when-serdes",level:2},{value:"How To SerDes In Roblox?",id:"how-to-serdes-in-roblox",level:2},{value:"Buffers Are The Key",id:"buffers-are-the-key",level:3}],c={toc:d},p="wrapper";function u(e){let{components:t,...r}=e;return(0,a.kt)(p,(0,n.Z)({},c,r,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"what-is-serdes"},"What Is SerDes?"),(0,a.kt)("p",null,"Serdes is a common abbreviation used for ",(0,a.kt)("strong",{parentName:"p"},"Serialization Deserialization"),"."),(0,a.kt)("h2",{id:"why-serdes"},"Why SerDes?"),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"SerDes")," is a way to minimize bandwidth and save space by reducing the size of data. ",(0,a.kt)("strong",{parentName:"p"},"It is to give the player a better experience.")),(0,a.kt)("h3",{id:"minimizing-latency"},"Minimizing Latency"),(0,a.kt)("p",null,"In the world of distributed systems, we often need to send data over the network and receive it on the other end. The time that takes is proportional to how large the data is. The smaller the data, the less time it takes and the less latency we have, resulting in a better player experience."),(0,a.kt)("h3",{id:"saving-space"},"Saving Space"),(0,a.kt)("p",null,"In the world of persistent data storage, we often need to store data across servers in data banks, such as Roblox DataStores. The amount of space that takes up on disks is proportional to how large the data is. Smaller data means less required storage space, which means we can store more data and take less time to save and load it."),(0,a.kt)("h2",{id:"when-serdes"},"When SerDes?"),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"SerDes")," is used whenever we need to compress data in a way that we can fully retrieve the original version of it, such as when we need to send data over the network or store it in data banks. Common use cases include:"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"Animations"),(0,a.kt)("li",{parentName:"ul"},"Movement"),(0,a.kt)("li",{parentName:"ul"},"Physics"),(0,a.kt)("li",{parentName:"ul"},"Saving / Loading")),(0,a.kt)("h2",{id:"how-to-serdes-in-roblox"},"How To SerDes In Roblox?"),(0,a.kt)("h3",{id:"buffers-are-the-key"},"Buffers Are The Key"),(0,a.kt)("p",null,"The only three arbitrarily-sized datatypes in Luau are the ",(0,a.kt)("inlineCode",{parentName:"p"},"string"),", ",(0,a.kt)("inlineCode",{parentName:"p"},"buffer"),", and ",(0,a.kt)("inlineCode",{parentName:"p"},"table")," datatypes. Tables can only be composed of primitive datatypes or other tables, and strings have both performance and memory overheads. Therefore if we need more control over the data we need to serialize, we should use buffers. With buffers, we have access to individual byte manipulation."))}u.isMDXComponent=!0}}]);