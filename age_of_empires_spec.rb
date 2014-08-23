require 'rspec'

module Atacante
  def ataca_a(otro_guerrero)
    if (potencial_ataque_real >
        otro_guerrero.potencial_defensivo)
      diferencia = potencial_ataque_real -
          otro_guerrero.potencial_defensivo
      otro_guerrero.recibir_danio(diferencia)
    end
    @descansado = false
  end

  def potencial_ataque_real
    if (@descansado)
      self.potencial_ataque * 2
    else
      self.potencial_ataque
    end
  end

  def potencial_ataque
    raise 'Deberia implementarme en la subclase'
  end

  def descansar
    @descansado = true
  end

end

module Observable
  attr_accessor :interesados

  def interesados
    @interesados = @interesados || []
    @interesados
  end

  def agregar_interesado(interesado)
    self.interesados << interesado
  end

  def notificar
    self.interesados.each {
        |interesado|
      interesado.call(self)
    }
  end
end

module Defensor
  include Observable
  attr_accessor :energia, :potencial_defensivo

  def recibir_danio(diferencia)
    self.energia = self.energia - diferencia
    self.notificar
  end

  def descansar
    self.energia += 10
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
  alias :descansar_atacante :descansar
  include Defensor
  alias :descansar_defensor :descansar

  attr_accessor :potencial_ataque

  def initialize
    self.energia = 100
    self.potencial_ataque = 50
    self.potencial_defensivo = 30
  end

  def descansar
    self.descansar_atacante
    self.descansar_defensor
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

  def lastimaron_a(unidad)
    self.curar(unidad)
  end
end


class Kamikaze
  include Defensor
  include Atacante

  attr_accessor :potencial_ataque

  def initialize
    self.energia = 100
    self.potencial_ataque = 500
    self.potencial_defensivo = 30
  end

  def ataca_a(unidad)
    super
    self.energia = 0
  end

end

class Ejercito
  attr_accessor :retirado, :estrategia_ataques

  def self.nuevo_ejercito_cobarde
    ejercito = Ejercito.new
    ejercito.estrategia_ataques = Cobarde.new
    ejercito
  end

  def self.nuevo_ejercito_descansador
    ejercito = Ejercito.new
    ejercito.estrategia_ataques = Descansador.new
    ejercito
  end

  def agregar_unidad(unidad)
    unidad.agregar_interesado(lambda {
        |unidad|
      self.lastimaron_a(unidad)
    })
  end

  def lastimaron_a(unidad)
    estrategia_ataques.lastimaron_a(self, unidad)
  end
end
class Cobarde
  def lastimaron_a(ejercito, unidad)
    ejercito.retirado = true
  end
end
class Descansador
  def lastimaron_a(ejercito, unidad)
    unidad.descansar
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

  it 'cuando un misil descansa ataca doble' do
    muralla = Muralla.new
    misil = Misil.new
    misil.descansar

    misil.ataca_a(muralla)

    muralla.energia.should == (1000 - 120)
  end

  it 'cuando una muralla descansa suma 10 de energia' do
    muralla = Muralla.new

    muralla.descansar

    muralla.energia.should == 1010
  end


  it 'un guerrero cuando descansa genera el doble de daño y gana 10 de energía' do
    conan = Guerrero.new
    muralla = Muralla.new

    conan.descansar
    conan.ataca_a(muralla)

    muralla.energia.should == 1000 - 60
    conan.energia.should == 110
  end

  it 'un kamikaze debe descansar como atacante pero no como defensor' do
    kamikaze = Kamikaze.new
    energia_original = kamikaze.energia
    muralla = Muralla.new

    kamikaze.descansar
    kamikaze.energia.should == energia_original

    kamikaze.ataca_a(muralla)
    muralla.energia.should == 40
    kamikaze.energia.should == 0
  end

  # --------------------------------------

  it 'un ejercito cobarde se retira cuando cualquiera de sus unidades es atacada' do
    ejercito = Ejercito.nuevo_ejercito_cobarde
    conan = Guerrero.new
    atila = Guerrero.new
    ejercito.agregar_unidad(conan)

    atila.ataca_a(conan)

    ejercito.retirado.should == true
  end

  it 'un ejercito descansador hace descansar una unidad cuando es atacada' do
    ejercito = Ejercito.nuevo_ejercito_descansador
    conan = Guerrero.new
    atila = Guerrero.new
    ejercito.agregar_unidad(conan)

    atila.ataca_a(conan)

    conan.energia.should == (100 - 20 + 10)
  end

  # ---------------------------------------

  it 'cuando atila es atacado el mago lo cura' do
    mago = Mago.new
    atila = Guerrero.new

    atila.agregar_interesado(lambda {
        |unidad| mago.curar(unidad)
    })
    conan = Guerrero.new

    conan.ataca_a(atila)

    atila.energia.should == (100 - 20 + 20)
  end

  it 'cuando atila es atacado el mago lo teletransporta' do
    mago = Mago.new
    atila = Guerrero.new
    atila.agregar_interesado(lambda {
        |unidad|
      mago.teletransportar(unidad)
    })
    conan = Guerrero.new

    conan.ataca_a(atila)

    mago.teletransportando.include?(atila).should == true
  end

  it 'bloques locos' do
    a = 5
    bloque = lambda {
      a
    }

    bloque.call().should == 5

    a = 6
    bloque.call().should == 6
  end


  it 'bloques locos2' do
    a = 5
    bloque = lambda {
      a = 3
    }

    a.should == 5
    bloque.call()
    a.should == 3
  end


end










