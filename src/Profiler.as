package  {
    public class Profiler {
        private static var instance:Profiler;

        public static function get profiler():Profiler {
                if (!Profiler.instance) Profiler.instance = new Profiler;
                return Profiler.instance;
        }

        private var data:Object = {};

        public function profile(fn:String, dur:int):void {
                if (!data.hasOwnProperty(fn)) data[fn] = new Number(0);
                data[fn] += dur / 1000.0;
        }

        public function clear():void {
                data = { };
        }

        public function get stats():String {
                var st:String = "";
                for (var fn:String in data) {
                        st += fn + ":\t" + data[fn] + "\n";
                }
                return st;
        }
    }
}
