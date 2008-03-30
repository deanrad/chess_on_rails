
var turnRow;

var t = new Template ( "<tr><td>?.</td><td>#{notation}</td><td></td></tr>");
for( var i = 0; i < moves.length; i++ ){
  var m = moves[i];
  
    //todo tweatk this
    //new Insertion.After( $('turn_template'), t.evaluate(m) );
    turnRow = t.evaluate(m);
    new Insertion.Bottom( $('turn_container'), turnRow );

};