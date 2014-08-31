require 'rspec'
require_relative '../src/domain/age_of_empires'
require_relative '../src/fwk/versionador'

module Versionable

  def version
    @version = @version || 0
  end

  def versionar
    @version = self.version + 1
  end
end

class Object
  include Versionable
end

describe 'Versionador' do

  it 'deberia tener una version' do
    atila = Guerrero.new

    atila.version.should == 0
  end

  it 'deberia versionar' do
    atila = Guerrero.new
    atila.versionar

    atila.version.should == 1
  end

  it 'deberia funcionar tambien para cualquier otra cosa' do
    a_string = 'Hola Mundo'
    a_string.version.should == 0
    a_string.versionar
    a_string.version.should == 1
  end
end