module Observable
  attr_accessor :interesados

  def interesados
    @interesados = @interesados || []
    @interesados
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