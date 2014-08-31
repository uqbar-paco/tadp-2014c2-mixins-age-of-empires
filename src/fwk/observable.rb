module Observable
  attr_accessor :interesados

  def interesados
    @interesados = @interesados || []
    @interesados
  end

  def agregar_interesado(interesado, selector)
    # bloque = lambda { |objeto|
    #   interesado.send selector, objeto
    # }

    self.interesados << interesado.method(selector)
  end

  def agregar(algo_para_hacer)
    self.interesados << algo_para_hacer
  end

  def notificar
    self.interesados.each {
        |interesado|
      interesado.call(self)
    }
  end
end