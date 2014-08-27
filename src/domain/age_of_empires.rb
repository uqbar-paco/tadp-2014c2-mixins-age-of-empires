require_relative '../fwk/observable'
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
    unidad.agregar_interesado( self, :lastimaron_a )
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










