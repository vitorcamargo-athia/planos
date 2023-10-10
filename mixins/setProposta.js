var setProposta = {
  methods: {
    update(campo, valor) {
      this.$store.dispatch("update", {
        campo: campo, value: valor
      });
    },
    updateDependente(valor, index) {
      this.$store.dispatch("updateDependente", {valor: valor, index: index});
    },
    updateBeneficiario(valor, index) {
      this.$store.dispatch("updateBeneficiario", {valor: valor, index: index});
    },
    updateMensal(valor) {
      this.$store.dispatch("updateMens", {valor: valor});
    },
    updateExtra(valor) {
      this.$store.dispatch("updateExtras", {valor: valor});
    },
    updateCrem(valor) {
      this.$store.dispatch("updateCremacao", {valor: valor});
    }
  }
}

export default setProposta;
