(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
"use strict";

rpc.exports = {
  memorydump: function memorydump(address, size) {
    return new NativePointer(address).readByteArray(size);
  },
  scandex: function scandex() {
    var result = [];
    Process.enumerateRanges('r--').forEach(function (range) {
      // @TODO
      // if (range.size > 8 && range.base.readCString(4) != "dex\n") {
      //     if(range.size > 0x24 && range.base.add(0x20).readInt() < range.size){
      //
      //     }
      // }
      try {
        Memory.scanSync(range.base, range.size, "64 65 78 0a 30 33 35 00").forEach(function (match) {
          var range = Process.findRangeByAddress(match.address);

          if (range != null && range.size < match.address.toInt32() + 0x24 - range.base.toInt32()) {
            return;
          }

          var dex_size = match.address.add("0x20").readInt();

          if (range != null) {
            if (range.file) {
              if (range.file.path && (range.file.path.startsWith("/data/app/") || range.file.path.startsWith("/data/dalvik-cache/") || range.file.path.startsWith("/system/"))) {
                return;
              }
            }

            if (match.address.toInt32() + dex_size > range.base.toInt32() + range.size) {
              return;
            }
          }

          result.push({
            "addr": match.address,
            "size": dex_size
          });
        });
      } catch (e) {}
    });
    return result;
  }
};

},{}]},{},[1])
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIm5vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCJhZ2VudC9pbmRleC50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQTs7O0FDQUEsR0FBRyxDQUFDLE9BQUosR0FBYztBQUNWLEVBQUEsVUFBVSxFQUFFLG9CQUFVLE9BQVYsRUFBbUIsSUFBbkIsRUFBdUI7QUFDL0IsSUFBQSxPQUFPLENBQUMsR0FBUixDQUFZLEtBQVo7QUFDQSxXQUFPLElBQUksYUFBSixDQUFrQixPQUFsQixFQUEyQixhQUEzQixDQUF5QyxJQUF6QyxDQUFQO0FBQ0gsR0FKUztBQUtWLEVBQUEsT0FBTyxFQUFFLG1CQUFBO0FBQ0wsUUFBSSxNQUFNLEdBQVUsRUFBcEI7QUFDQSxJQUFBLE9BQU8sQ0FBQyxlQUFSLENBQXdCLEtBQXhCLEVBQStCLE9BQS9CLENBQXVDLFVBQVUsS0FBVixFQUFlO0FBQ2xEO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSxVQUFJO0FBQ0EsUUFBQSxNQUFNLENBQUMsUUFBUCxDQUFnQixLQUFLLENBQUMsSUFBdEIsRUFBNEIsS0FBSyxDQUFDLElBQWxDLEVBQXdDLHlCQUF4QyxFQUFtRSxPQUFuRSxDQUEyRSxVQUFVLEtBQVYsRUFBZTtBQUN0RixjQUFJLEtBQUssR0FBRyxPQUFPLENBQUMsa0JBQVIsQ0FBMkIsS0FBSyxDQUFDLE9BQWpDLENBQVo7O0FBQ0EsY0FBSSxLQUFLLElBQUksSUFBVCxJQUFpQixLQUFLLENBQUMsSUFBTixHQUFjLEtBQUssQ0FBQyxPQUFOLENBQWMsT0FBZCxLQUEwQixJQUExQixHQUFpQyxLQUFLLENBQUMsSUFBTixDQUFXLE9BQVgsRUFBcEUsRUFBMkY7QUFDdkY7QUFDSDs7QUFDRCxjQUFJLFFBQVEsR0FBRyxLQUFLLENBQUMsT0FBTixDQUFjLEdBQWQsQ0FBa0IsTUFBbEIsRUFBMEIsT0FBMUIsRUFBZjs7QUFDQSxjQUFJLEtBQUssSUFBSSxJQUFiLEVBQW1CO0FBQ2YsZ0JBQUksS0FBSyxDQUFDLElBQVYsRUFBZ0I7QUFDWixrQkFBSSxLQUFLLENBQUMsSUFBTixDQUFXLElBQVgsS0FDQyxLQUFLLENBQUMsSUFBTixDQUFXLElBQVgsQ0FBZ0IsVUFBaEIsQ0FBMkIsWUFBM0IsS0FDTSxLQUFLLENBQUMsSUFBTixDQUFXLElBQVgsQ0FBZ0IsVUFBaEIsQ0FBMkIscUJBQTNCLENBRE4sSUFFTSxLQUFLLENBQUMsSUFBTixDQUFXLElBQVgsQ0FBZ0IsVUFBaEIsQ0FBMkIsVUFBM0IsQ0FIUCxDQUFKLEVBR29EO0FBQ2hEO0FBQ0g7QUFDSjs7QUFDRCxnQkFBSSxLQUFLLENBQUMsT0FBTixDQUFjLE9BQWQsS0FBMEIsUUFBMUIsR0FBcUMsS0FBSyxDQUFDLElBQU4sQ0FBVyxPQUFYLEtBQXVCLEtBQUssQ0FBQyxJQUF0RSxFQUE0RTtBQUN4RTtBQUNIO0FBQ0o7O0FBQ0QsVUFBQSxNQUFNLENBQUMsSUFBUCxDQUFZO0FBQ1Isb0JBQVEsS0FBSyxDQUFDLE9BRE47QUFFUixvQkFBUTtBQUZBLFdBQVo7QUFJSCxTQXZCRDtBQXdCSCxPQXpCRCxDQXlCRSxPQUFPLENBQVAsRUFBVSxDQUVYO0FBQ0osS0FsQ0Q7QUFtQ0EsV0FBTyxNQUFQO0FBQ0g7QUEzQ1MsQ0FBZCIsImZpbGUiOiJnZW5lcmF0ZWQuanMiLCJzb3VyY2VSb290IjoiIn0=
