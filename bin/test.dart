import 'dart:async';
import 'dart:convert';
import './redis.dart';


testparser(){
  List data =  new Utf8Encoder().convert("*3\r\n*1\r\n:3\r\n+Foo\r\n+Barzor\r\n ");
  var stream = new LazyStream.fromstream(new Stream.fromIterable(data));  
  
  RedisParser.parseredisresponse(stream).then((v) {
    print("$v");
  });
}

test_performance(){
  const int N = 200000;
  int count=0;
  int start;
  
  RedisConnection conn = new RedisConnection();
  conn.connect('localhost',6379).then((_){
    print("test started, please wait ...");
    start =  new DateTime.now().millisecondsSinceEpoch;
    Command command = new Command(conn.sendraw);
    conn.pipe_start();
    for(int i=0;i<N;i++){
      command.set("العربية $i","$i")
      .then((v){
        assert(v=="OK");
        count++;
        if(count == N){
          double diff = (new DateTime.now().millisecondsSinceEpoch - start)/1000.0;
          double perf = N/diff;
          print("$N operations done in $diff s\nperformance $perf/s");
        }
      });
    }
    conn.pipe_end();
   });
}


test_transations(){
  RedisConnection conn = new RedisConnection();
  conn.connect('localhost',6379).then((_){
    Transation trans = new Transation(conn);
    
    trans.multi().then((v){
        print(v);
        trans.send(["SET","test","0"]);
        for(int i=1;i<=100000;++i){
          trans.send(["INCR","test"]).then((v){
            assert(i==v);
          });
        }
        trans.send(["GET","test"]).then((v){print(v);});
        trans.exec();
    });
  });
}

main(){
  test_performance();
}