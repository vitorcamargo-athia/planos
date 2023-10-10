<template>
  <div class="box">
    <div class="columns">
      <div class="column has-text-centered">

        <strong >Débito em conta</strong>

      </div>
    </div>
    <div class="columns field">
      <div class="column has-text-right">
        <label class="label">Agência:</label>
      </div>
      <div class="column control">
        <the-mask
          class="input"
          :mask="['###', '###-#', '###-##']"
          v-model="valueFields.agencia"
          @input="
            updateValue('num_cartao', $event);
          "
          id="agencia"
        />
      </div>
    </div>

    <div class="columns field">
      <div class="column has-text-right">
        <label class="label">Conta:</label>
      </div>
      <div class="column control">
        <the-mask
          class="input"
          :mask="['###-#', '####-#', '#####-#', '######-#']"
          v-model="valueFields.conta"
          @input="
            updateValue('num_cartao', $event);
          "
          id="conta"
        />
      </div>
    </div>

    <div class="columns field">
      <div class="column has-text-right">
        <label class="label">CPF / CNPJ do titular:</label>
      </div>
      <div class="column control">
        <input
          type="text"
          class="input"
          id="v-card-name"
          @input="updateValue('nome_cartao', $event.target.value)"
          v-model="valueFields.cpf"
        />
      </div>
    </div>

    <div class="columns field">
      <div class="column has-text-right">
        <label class="label">Razão Social do titular:</label>
      </div>
      <div class="column control">
        <input
          type="text"
          class="input"
          id="v-card-name"
          @input="updateValue('nome_cartao', $event.target.value)"
          v-model="valueFields.razaoSocial"
        />
      </div>
    </div>

  </div>
</template>

<script>
import { TheMask } from "vue-the-mask";
import setProposta from "@/mixins/setProposta";

export default {
  mixins:[setProposta],

  data: () => ({

    valueFields: {
      cpf: "",
      agencia: "",
      conta: "",
      razaoSocial: "",
      cardYear: "",
      cardCvv: "",
      bandeira: "",
    },
  }),
  components: { TheMask },
  props:[
    "card"
  ],
  methods: {
    updateValue(campo, value) {

      this.update(campo,value);

      this.$emit("change", {
        campo: campo,
        valor: value,
      });
    },
  },
};
</script>

<style scoped>

</style>
