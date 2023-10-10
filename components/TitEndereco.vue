<template>
  <article class="panel is-info">
    <p class="panel-heading">
      Endereço do Titular
    </p>
    <div class="box">
      <b-field label="CEP *" grouped>
        <p class="control">
          <the-mask class="input" v-model="cep" :required="!cep" :mask="'#####-###'" type="text"
            @input.native="updateValue('cep', cep)" />
        </p>
        <p class="control">
          <b-button class="button" @click="preencheEndereco()">Buscar</b-button>
        </p>
      </b-field>

      <b-field grouped group-multiline>
        <b-field label="Endereço *" expanded>
          <input class="input" :disabled="getLogradouro" v-model.lazy="logradouro" type="text" :required="!logradouro"
            @input="updateValue('logradouro', $event.target.value)" />
        </b-field>
        <b-field label="Número *">
          <input class="input" v-model.lazy="numero" type="text" required
            @input="updateValue('numero', $event.target.value)" />
        </b-field>
        <b-field label="Complemento" expanded>
          <input class="input" v-model.lazy="complemento" type="text"
            @input="updateValue('complemento', $event.target.value)" />
        </b-field>
      </b-field>

      <b-field grouped group-multiline>
        <b-field label="Bairro *" expanded>
          <input class="input" v-model.lazy="bairro" :disabled="getBairro" type="text" required
            @input="updateValue('bairro', $event.target.value)" />
        </b-field>
        <b-field label="Cidade *" expanded>
          <input class="input" v-model.lazy="cidade" :disabled="getCidade" type="text" required
            @input="updateValue('cidade', $event.target.value)" />
        </b-field>
        <b-field label="Estado *">
          <div class="select is-fullwidth">
            <select v-model="uf" :disabled="getEstado" @input="updateValue('uf', $event.target.value)">
              <option value="AC">Acre</option>
              <option value="AL">Alagoas</option>
              <option value="AP">Amapá</option>
              <option value="AM">Amazonas</option>
              <option value="BA">Bahia</option>
              <option value="CE">Ceará</option>
              <option value="DF">Distrito Federal</option>
              <option value="ES">Espírito Santo</option>
              <option value="GO">Goiás</option>
              <option value="MA">Maranhão</option>
              <option value="MT">Mato Grosso</option>
              <option value="MS">Mato Grosso do Sul</option>
              <option value="MG">Minas Gerais</option>
              <option value="PA">Pará</option>
              <option value="PB">Paraíba</option>
              <option value="PR">Paraná</option>
              <option value="PE">Pernambuco</option>
              <option value="PI">Piauí</option>
              <option value="RJ">Rio de Janeiro</option>
              <option value="RN">Rio Grande do Norte</option>
              <option value="RS">Rio Grande do Sul</option>
              <option value="RO">Rondônia</option>
              <option value="RR">Roraima</option>
              <option value="SC">Santa Catarina</option>
              <option value="SP">São Paulo</option>
              <option value="SE">Sergipe</option>
              <option value="TO">Tocantins</option>
            </select>
          </div>
        </b-field>
      </b-field>
    </div>
  </article>
</template>

<script>
import { TheMask } from "vue-the-mask";
import setProposta from "../mixins/setProposta";

export default {
  mixins: [setProposta],

  name: "TitEndereco",
  data() {
    return {
      cep: "",
      logradouro: "",
      numero: "",
      complemento: "",
      bairro: "",
      cidade: "",
      uf: "",
      getLogradouro: false,
      getBairro: false,
      getCidade: false,
      getEstado: false
    };
  },
  components: { TheMask },
  props: ["endereco"],
  mounted() {
    if (this.endereco) {
      this.cep = this.endereco.cep;
      this.logradouro = this.endereco.logradouro;
      this.numero = this.endereco.numero;
      this.complemento = this.endereco.complemento;
      this.bairro = this.endereco.bairro;
      this.cidade = this.endereco.cidade;
      this.uf = this.endereco.uf;
    }
  },
  methods: {
    updateValue(campo, value) {
      this.update(campo, value);

      this.$emit("change", {
        campo: campo,
        valor: value,
      });
    },
    preencheEndereco() {
      fetch("https://viacep.com.br/ws/" + this.cep + "/json/")
        .then((res) => res.json())
        .then((res) => {

          if (res.logradouro) {
            this.logradouro = res.logradouro;
            this.updateValue("logradouro", this.logradouro);
            this.getLogradouro = true;
          }

          if (res.bairro) {
            this.bairro = res.bairro;
            this.updateValue("bairro", this.bairro);
            this.getBairro = true;
          }

          if (res.localidade) {
            this.cidade = res.localidade;
            this.updateValue("cidade", this.cidade);
            this.getCidade = true;
          }

          if (res.uf) {
            this.uf = res.uf;
            this.updateValue("uf", this.uf);
            this.getEstado = true;
          }
        });
    },
  },
}
</script>

<style scoped></style>
