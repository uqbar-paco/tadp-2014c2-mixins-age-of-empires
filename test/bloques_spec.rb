require 'rspec'

describe 'Referencias en bloques' do
  it 'cambiar valor variable fuera del bloque' do
    a = 5
    bloque = lambda {
      a
    }

    bloque.call().should == 5

    a = 6
    bloque.call().should == 6
  end


  it 'cambiar valor de la variable dentro del bloque' do
    a = 5
    bloque = lambda {
      a = 3
    }

    a.should == 5
    bloque.call()
    a.should == 3
  end

end