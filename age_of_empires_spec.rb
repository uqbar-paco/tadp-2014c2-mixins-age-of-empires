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

class Mago
  attr_accessor :teletransportando

  def initialize
    @teletransportando = []
  end

  def curar(unidad)
    unidad.energia += 20
  end

  def teletransportar(unidad)
    @teletransportando << unidad
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

  # ===================================================

  # it 'cuando un misil descansa ataca doble' do
  #   muralla = Muralla.new
  #   misil = Misil.new
  #   misil.descansar
  #
  #   misil.ataca_a(muralla)
  #
  #   muralla.energia.should == (1000 - 120)
  # end
  #
  # it 'cuando una muralla descansa suma 10 de energia' do
  #   muralla = Muralla.new
  #
  #   muralla.descansar
  #
  #   muralla.energia.should == 1010
  # end
  #
  # it 'un gerrero cuando descansa genera el doble de daño y gana 10 de energía' do
  #   conan = Guerrero.new
  #   muralla = Muralla.new
  #
  #   conan.descansar
  #   conan.ataca_a(muralla)
  #
  #   muralla.energia.should == 1000 - 60
  #   conan.energia.should == 110
  # end
  #
  # it 'un kamikaze debe descansar como atacante pero no como defensor' do
  #   kamikaze = Kamikaze.new
  #   energia_original = kamikaze.energia
  #   muralla = Muralla.new
  #
  #   kamikaze.descansar
  #   kamikaze.energia.should == energia_original
  #
  #   kamikaze.ataca_a(muralla)
  #   muralla.energia.should == 40
  #   kamikaze.energia.should == 0
  # end
  #
  # # --------------------------------------
  #
  # it 'un ejercito cobarde se retira cuando cualquiera de sus unidades es atacada' do
  #   ejercito = EjercitoCobarde.new
  #   conan = Guerrero.new
  #   atila = Guerrero.new
  #   ejercito.agregar_unidad(conan)
  #
  #   atila.ataca_a(conan)
  #
  #   ejercito.retirado?.should == true
  # end
  #
  # it 'un ejercito descansador hace descansar una unidad cuando es atacada' do
  #   ejercito = EjercitoDescansador.new
  #   conan = Guerrero.new
  #   atila = Guerrero.new
  #   ejercito.agregar_unidad(conan)
  #
  #   atila.ataca_a(conan)
  #
  #   conan.energia.should == (100 - 20 + 10)
  # end
  #
  # # ---------------------------------------
  #
  # it 'cuando atila es atacado el mago lo cura' do
  #   mago = Mago.new
  #   atila = Guerrero.new
  #   # asociar mago con atila
  #   conan = Guerrero.new
  #
  #   conan.atacar_a(atila)
  #
  #   atila.energia.should == (100 - 20 + 20)
  # end

end
