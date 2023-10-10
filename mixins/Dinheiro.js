var Dinheiro = {
  methods: {
    formatPrice(value) {
      if (value == 0) return '0,00';
      var val;
      try {
        val = Number(value.replace(",", "."));
      } catch (e) {
        val = value;
      }
      const valueString = val.toFixed(2).replace(".", ",");
      return valueString.replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    }
  }
};

export default Dinheiro;
