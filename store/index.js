
// holds your root state
export const state = () => ({
  proposta: {
    //VARIÁVEIS DE CONTROLE
    verificado: false,
    concorda1: false,
    concorda2: false,

    //VARIAVEIS DOS DEPENDENTES
    dpai: false,
    dmae: false,
    dsogro: false,
    dsogra: false,

    //DADOS
    dependentes: [],
    beneficiarios: [],
    nome: "",
    email: "",
    crematorio: "n",
    conjuge: false,
    celular: "",
    dataNasc: "",
    cpf: "",
    rg: "",
    sexo: "",
    anexos: [],
    cep: "",
    logradouro: "",
    numero: "",
    complemento: "",
    bairro: "",
    cidade: "",
    estado: "",
    metodoPag: 0,
    mcobranca: 1,
    nome_cartao: "",
    num_cartao: "",
    validade_mes: "",
    validade_ano: "",
    cvv: "",
    bandeira: "",
    tipo: "C",
    cpf_titular: "",
    estCivil: 1

  },
  mensalidades: [],
  extras:[],
  cremacao:0
})

// contains your actions
export const actions = {
  update({ state, commit }, dado) {
    commit('setProposta', dado)
  },

  updateDependente({ state, commit }, { valor, index }) {
    commit('setDependente', { valor, index })
  },
  updateBeneficiario({ state, commit }, { valor, index }) {
    commit('setBeneficiario', { valor, index })
  },
  updateMens({ state, commit }, { valor }) {
    commit('setMensalidades', { valor })
  },
  updateExtras({ state, commit }, { valor }) {
    commit('setExtras', { valor })
  },
  updateCremacao({ state, commit }, { valor }) {
    commit('setCremacao', { valor })
  }
}
// contains your mutations
export const mutations = {
  setProposta(state, { campo, value }) {
    state.proposta[campo] = value
  },
  setDependente(state, { valor, index }) {
    if (index < state.proposta.dependentes.length) {
      state.proposta.dependentes[index] = valor;
    } else {
      state.proposta.dependentes.push(valor);
    }

  },

  setBeneficiario(state, { valor, index }) {
    if (state.proposta.beneficiarios[index] !== undefined) {
      state.proposta.beneficiarios[index] = valor;
    } else {
      state.proposta.beneficiarios.push(valor);
    }

  },
  setMensalidades(state, value) {
    state.mensalidades = value.valor
  },
   setExtras(state, value) {
    state.extras = value.valor
  },
  setCremacao(state, value) {
    state.cremacao = Number(value.valor.replace(",", "."))
  },
}


