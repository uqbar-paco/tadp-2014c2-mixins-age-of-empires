require 'rspec'
require_relative '../src/fwk/observable'
require_relative '../src/domain/age_of_empires'

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


  it 'un guerrero cuando descansa genera el doble de danio y gana 10 de energia' do
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

    atila.agregar_interesado(mago, :curar)
    conan = Guerrero.new

    conan.ataca_a(atila)

    atila.energia.should == (100 - 20 + 20)
  end

  it 'cuando atila es atacado el mago lo teletransporta' do
    mago = Mago.new
    atila = Guerrero.new
    atila.agregar( lambda {|unidad |
      mago.teletransportar(unidad)
    })
    conan = Guerrero.new

    conan.ataca_a(atila)

    mago.teletransportando.include?(atila).should == true
  end

  it 'cuando atila es atacado pasan cosas locas' do
    atila = Guerrero.new

    atila.singleton_class.send(:define_method,
      :comerse_un_pollo, lambda {
      self.energia += 20
    })

    atila.agregar(lambda {|unidad|
        unidad.descansar
        unidad.comerse_un_pollo})
    conan = Guerrero.new

    conan.ataca_a(atila)
    atila.energia.should == (100 - 20 + 10 + 20)
  end

end










