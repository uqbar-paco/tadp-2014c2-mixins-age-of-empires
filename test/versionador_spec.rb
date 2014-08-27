require 'rspec'
require_relative '../src/domain/age_of_empires'
require_relative '../src/fwk/versionador'

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
    3.version.should == 0
    3.versionar
    3.version.should == 1
  end
end