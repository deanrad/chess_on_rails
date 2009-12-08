require 'pp'

if ENV['TEST_CONTROLLER']=="1"

class TestController < ApplicationController

  def _
    if params[:query]
      evalout = pp_to_s( eval(params[:query]) ) rescue 'ERROR :)'
      output = UI.sub("$OUTPUT", text_to_html(evalout) ).sub('$INPUT', params[:query] )
      render :text => (output )
    elsif request.get?
      render :text => UI.sub("$OUTPUT", '').sub('$INPUT', '' )
    end
  end
  def index
    render :text => 'Test Controller usage: http://localhost:3001/test/_ (pass ENV["TEST_CONTROLLER"]="1")'
  end

  def pp_to_s(x)
    out_old = $>
    $> = StringIO.new
    pp(x)
    result = $>.string
  ensure
    $> = out_old
    result
  end

  def text_to_html(x, wrap_and_pre = true)
    x.gsub!('&', "\01")
    x.gsub!('<', '&lt;')
    x.gsub!('>', '&gt;')
    x.gsub!("\01", '&amp;')
    x = "<pre>\n" + x + "\n</pre>\n" if wrap_and_pre
    x
  end

      UI = <<-EOF
<html><body><form method=GET>
<textarea name='query' rows=5 cols="70">$INPUT</textarea>
<br/>
<input type=submit value="Submit"/>
<br/>
$OUTPUT
</form></body></html>
EOF

end

end # if ENV['TEST_CONTROLLER']=="1"
