require 'rspec'

module Atacante
  def ataca_a(otro_guerrero)
    if(self.potencial_ataque >
        otro_guerrero.potencial_defensivo)
      diferencia = self.potencial_ataque -
          otro_guerrero.potencial_defensivo
      otro_guerrero.recibir_danio(diferencia)
    end
  end

  def potencial_ataque
    raise 'Deberia implementarme en la subclase'
  end

end

module Defensor
  attr_accessor :energia, :potencial_defensivo
  def recibir_danio(diferencia)
    self.energia = self.energia - diferencia
  end

end

class Misil
  include Atacante
  def potencial_ataque
    80 # m*c^2 redondeado
  end
end

class Muralla
  include Defensor
  def initialize
    self.energia = 1000
    self.potencial_defensivo = 40
  end
end

class Guerrero
  include Atacante
  include Defensor

  attr_accessor :potencial_ataque

  def initialize
    self.energia = 100
    self.potencial_ataque = 50
    self.potencial_defensivo = 30
  end

end

class Espadachin < Guerrero
  attr_accessor :habilidad, :espada
  def initialize
    super
    self.habilidad = 1
    self.espada = 30
  end

  def potencial_ataque
    super + self.habilidad * self.espada
  end
end

describe 'Age of Empires' do

  it 'un guerrero ataca a otro' do
    conan = Guerrero.new
    atila = Guerrero.new

    conan.ataca_a(atila)

    atila.energia.should == 80
  end

  it 'un guerrero debil no dania a uno mas fuerte' do
    ringo = Guerrero.new
    ringo.potencial_ataque = 10
    atila = Guerrero.new

    ringo.ataca_a(atila)

    atila.energia.should == 100
  end

  it 'un espadachin ataca a un guerrero' do
    conan = Guerrero.new
    zorro = Espadachin.new

    zorro.ataca_a(conan)

    conan.energia.should == 50
  end

  it 'un misil ataca a un guerrero' do
    conan = Guerrero.new
    misil = Misil.new

    misil.ataca_a(conan)

    conan.energia.should == 50
  end

  it 'un misil no puede ser atacado' do
    misil = Misil.new

    expect {
      misil.recibir_danio(10)
    }.to raise_error NoMethodError

  end

  it 'un guerrero ataca a una muralla' do
    conan = Guerrero.new
    muralla = Muralla.new

    conan.ataca_a(muralla)

    muralla.energia.should == 990
  end

  it 'una muralla no puede atacar' do
    muralla = Muralla.new

    expect {
      muralla.atacar_a(Guerrero.new)
    }.to raise_error NoMethodError

  end

end