"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[53],{1109:e=>{e.exports=JSON.parse('{"pluginId":"default","version":"current","label":"Next","banner":null,"badge":false,"noIndex":false,"className":"docs-version-current","isLast":true,"docsSidebars":{"defaultSidebar":[{"type":"link","label":"What Is SerDes?","href":"/Squash/docs/intro","docId":"intro"},{"type":"link","label":"Why Squash?","href":"/Squash/docs/why","docId":"why"},{"type":"link","label":"How To Serialize?","href":"/Squash/docs/how","docId":"how"},{"type":"link","label":"Packet Format And Insights","href":"/Squash/docs/binary","docId":"binary"},{"type":"link","label":"Benchmarks and Measurements","href":"/Squash/docs/benchmarks","docId":"benchmarks"}]},"docs":{"benchmarks":{"id":"benchmarks","title":"Benchmarks and Measurements","description":"Eyeballed Lookup Table","sidebar":"defaultSidebar"},"binary":{"id":"binary","title":"Packet Format And Insights","description":"Strings are great for serializing data, but we need to know when to serialize. Certain kinds of data is cheaper to send over the network than others. This page is very technical, as it introduces the raw binary format remotes use internally and discusses the overhead of each type of data. If you are looking for a more high-level overview of the topic, check out the Why SerDes? or How To SerDes? pages.","sidebar":"defaultSidebar"},"how":{"id":"how","title":"How To Serialize?","description":"Every byte can represent 256 possible values. We can represent 256^2 = 65536 possible values with 2 bytes, 256^3 = 16777216 possible values with 3 bytes, and so on. There are many ways to interpret these bytes depending on context which is the key to serialization.","sidebar":"defaultSidebar"},"intro":{"id":"intro","title":"What Is SerDes?","description":"Serdes is a common abbreviation used for Serialization Deserialization.","sidebar":"defaultSidebar"},"why":{"id":"why","title":"Why Squash?","description":"Squash has come into existence to solve a common problem many developers end up facing. Imagine you are making a custom character controller and need to send updates to the server multiple times a second. If you don\'t play your cards right, you could end up sending an intolerable amount of data over the network per player. This is bad because it takes a lot of bandwidth to send and receive data over the network. Now imagine making a save / load system, depending on the amount of information you need to save and load, you can end up making the player wait a long time to save and load their data. This is bad because it reduces player retention rates, and lowers the overall quality of the player experience.","sidebar":"defaultSidebar"}}}')}}]);