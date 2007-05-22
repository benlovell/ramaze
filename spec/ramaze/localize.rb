#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'ya2yaml', 'ramaze/tool/localize'

Ramaze::Tool::Localize.trait :enable    => true,
                             :file      => 'spec/ramaze/conf/locale_%s.yaml'.freeze,
                             :languages => %w[en de]

Ramaze::Dispatcher::Action.trait[:filter] << Ramaze::Tool::Localize

class TCLocalize < Ramaze::Controller
  map '/'

  def hello lang = 'en'
    session[:LOCALE] = lang
    '[[hello]]'
  end

  def advanced lang = 'en'
    session[:LOCALE] = lang
    '[[this]] [[is]] [[a]] [[test]]'
  end
end

describe "Localize" do
  before :all do
    @dir = File.join(File.dirname(__FILE__), 'conf')
    FileUtils.mkdir_p(@dir)

    dict = {
      :de => {
        'hello'  => 'Hallo, Welt!',
        'this'   => 'Das',
        'is'     => 'ist',
        'a'      => 'ein',
        'test'   => 'Test',
      },
      :en => {
        'hello'  => 'Hello, World!',
        'this'   => 'this',
        'is'     => 'is',
        'a'      => 'a',
        'test'   => 'test',
    } }
    dict.each do |lang, dic|
      File.open(@dir/"locale_#{lang}.yaml", 'w+'){|fp| fp.print(dic.to_yaml)}
    end
    ramaze
  end

  it "hello world" do
    get('/hello').body.should == 'Hello, World!'
    get('/hello/de').body.should == 'Hallo, Welt!'
  end

  it "advanced" do
    get('/advanced').body.should == 'this is a test'
    get('/advanced/de').body.should == 'Das ist ein Test'
  end

  after :all do
    FileUtils.rm_rf(@dir)
  end
end
