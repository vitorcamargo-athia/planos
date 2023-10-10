<template>
  <div class="box">
    <div class="columns">
      <div class="column has-text-centered">
        <strong class="subtitle is-4">Dados do cartão</strong>
      </div>
    </div>
    <div class="columns">
      <div class="column">
        <div
          class="columns field"
          :class="{ mobile: isMobile }"
          v-if="!hide_tipo"
        >
          <div class="column has-text-right-desktop is-3-desktop">
            <label class="label">Tipo de Pagamento:</label>
          </div>
          <div class="column control">
            <div class="columns is-mobile forma-pagto">
              <div class="column">
                <label>
                  <input
                    type="radio"
                    class="radio"
                    v-model="valueFields.tipo"
                    @input="updateValue('tipo', $event.target.value)"
                    value="C"
                  />
                  Crédito
                </label>
              </div>
              <div class="column">
                <label>
                  <input
                    type="radio"
                    class="radio"
                    v-model="valueFields.tipo"
                    @input="updateValue('tipo', $event.target.value)"
                    value="D"
                  />
                  Débito
                </label>
              </div>
            </div>
          </div>
        </div>
        <div class="columns field" :class="{ mobile: isMobile }">
          <div class="column has-text-right-desktop is-3-desktop">
            <label class="label">Número do Cartão:</label>
          </div>
          <div class="column control">
            <the-mask
              class="input"
              :mask="['#### #### #### ####']"
              v-model="valueFields.cardNumber"
              type="tel"
              @input="
                updateValue('num_cartao', $event);
                changeBandeira();
              "
              id="v-card-number"
            />
          </div>
        </div>
        <div class="columns field" :class="{ mobile: isMobile }">
          <div class="column is-3-desktop has-text-right-desktop">
            <label class="label">Bandeira:</label>
          </div>
          <div class="column control">
            <div class="select">
              <select v-model="valueFields.bandeira" disabled="true">
                <option
                  v-for="(b, index) in bandeiras"
                  :value="b.value"
                  :key="index"
                >
                  {{ b.label }}
                </option>
              </select>
            </div>
          </div>
        </div>
        <div class="columns field" :class="{ mobile: isMobile }">
          <div class="column has-text-right-desktop is-3-desktop">
            <label class="label">Nome do Titular:</label>
          </div>

          <div class="column control">
            <input
              type="text"
              class="input"
              id="v-card-name"
              @input="updateValue('nome_cartao', $event.target.value)"
              v-model="valueFields.cardName"
            />
          </div>
        </div>
        <div class="columns field" :class="{ mobile: isMobile }">
          <div class="column has-text-right-desktop is-3-desktop">
            <label class="label">CPF do Titular:</label>
          </div>

          <div class="column control">
            <the-mask
              class="input"
              id="v-card-cpf"
              type="tel"
              :mask="['###.###.###-##']"
              @input="updateValue('cpf_titular', $event)"
              @blur.native="validarCPF()"
              v-model="valueFields.cpfTitular"
            />
          </div>
        </div>
        <div class="columns field is-mobile">
          <div class="column has-text-right is-3">
            <label class="label">Validade:</label>
          </div>
          <div class="column">
            <div class="columns is-mobile">
              <div class="column is-5">
                <input
                  type="tel"
                  class="input"
                  id="v-card-month"
                  @blur="
                    setMes();
                    updateValue('validade_mes', valueFields.cardMonth);
                  "
                  v-model="valueFields.cardMonth"
                  min="1"
                  max="12"
                  maxlength="2"
                  @keyup="skipToAno()"
                />
              </div>
              <div class="column is-1 is-size-4">/</div>
              <div class="column is-5">
                <input
                  type="tel"
                  class="input"
                  id="v-card-year"
                  @blur="
                    setAno();
                    updateValue('validade_ano', valueFields.cardYear);
                  "
                  v-model="valueFields.cardYear"
                  maxlength="4"
                />
              </div>
            </div>
          </div>
        </div>
        <div class="columns field is-mobile">
          <div class="column has-text-right is-3">
            <label class="label">CVV:</label>
          </div>
          <div class="column control">
            <div class="columns is-mobile">
              <div class="column is-5">
                <input
                  class="input"
                  id="v-card-cvv"
                  @input="updateValue('cvv', $event.target.value)"
                  type="tel"
                  v-model="valueFields.cardCvv"
                  maxlength="3"
                />
              </div>
              <div class="column"></div>
            </div>
          </div>
        </div>
      </div>
      <div class="column">
        <div class="is-offset-4 column">
          <div class="box cartao">
            <div class="columns num_cartao">
              <div class="column has-text-centered">
                <span class="is-size-5">{{ numCartao }}</span>
              </div>
            </div>
            <div class="columns cvv">
              <div class="column has-text-right">
                <span class="is-size-7">CVV: {{ cvv }}</span>
              </div>
            </div>
            <div class="columns valid-bandeira is-mobile">
              <div class="column">
                <span class="is-size-7">Valid: {{ validade }}</span>
              </div>
              <div class="column has-text-right">
                <img
                  :src="require(`~/assets/bandeiras/${bandeira}.png`)"
                  width="50px"
                />
              </div>
            </div>
            <div class="columns nome" :class="{ visa: bandeira == 'visa' }">
              <div class="column has-text-left">
                <span class="is-size-6">{{ nome }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { TheMask } from "vue-the-mask";
import { cpf } from "cpf-cnpj-validator";
import Mobile from "../mixins/Mobile";

export default {
  data: () => ({
    valueFields: {
      cardName: "",
      cardNumber: "",
      cardMonth: "",
      cardYear: "",
      cardCvv: "",
      bandeira: "",
      cpfTitular: "",
      tipo: "",
    },
    bandeiras: [
      { value: "visa", label: "Visa" },
      { value: "mastercard", label: "Mastercard" },
      { value: "diners", label: "Diners" },
      { value: "amex", label: "American Express" },
    ],
  }),
  mounted() {
    this.valueFields.cardName = this.dados.nome_cartao;
    this.valueFields.bandeira = this.dados.bandeira;
    this.valueFields.cpfTitular = this.dados.cpf_titular;
    this.valueFields.cardCvv = this.dados.cvv;
    this.valueFields.cardNumber = this.dados.num_cartao;
    this.valueFields.tipo = this.dados.tipo;
    this.valueFields.cardMonth = this.dados.validade_mes;
    this.valueFields.cardYear = this.dados.validade_ano;
  },
  name: "Cartao",
  props: ["dados", "hide_tipo"],
  components: { TheMask },
  mixins: [Mobile],
  methods: {
    skipToAno() {
      if (this.valueFields.cardMonth.length == 2)
        document.getElementById("v-card-year").focus();
    },
    validarCPF() {
      if (!cpf.isValid(this.valueFields.cpfTitular)) {
        this.$buefy.toast.open({ type: "is-danger", message: "CPF inválido!" });
      }
    },
    updateValue(campo, value) {
      this.$emit("change", {
        campo: campo,
        valor: value,
      });
    },
    setMes() {
      if (this.valueFields.cardMonth > 12) this.valueFields.cardMonth = 12;
      else if (this.valueFields.cardMonth < 1) this.valueFields.cardMonth = 1;

      if (
        this.valueFields.cardMonth < 10 &&
        this.valueFields.cardMonth > 0 &&
        this.valueFields.cardMonth.length == 1
      )
        this.valueFields.cardMonth = "0" + this.valueFields.cardMonth;
    },
    setAno() {
      if (this.valueFields.cardYear.length == 2)
        this.valueFields.cardYear = "20" + this.valueFields.cardYear;
      if (this.valueFields.cardYear.length == 3)
        this.valueFields.cardYear = "2" + this.valueFields.cardYear;

      var d = new Date();
      var y = d.getFullYear();

      if (this.valueFields.cardYear < y) this.valueFields.cardYear = y;
    },
    changeBandeira() {
      this.valueFields.bandeira = getBandeira(this.valueFields.cardNumber);
      this.updateValue("bandeira", this.valueFields.bandeira);

      function getBandeira(number) {
        // visa
        var re = new RegExp("^4");
        if (number.match(re) != null) return "visa";

        // Mastercard
        // Updated for Mastercard 2017 BINs expansion
        if (
          /^(5[1-5][0-9]{14}|2(22[1-9][0-9]{12}|2[3-9][0-9]{13}|[3-6][0-9]{14}|7[0-1][0-9]{13}|720[0-9]{12}))$/.test(
            number
          )
        )
          return "mastercard";

        // AMEX
        re = new RegExp("^3[47]");
        if (number.match(re) != null) return "amex";

        // Diners
        re = new RegExp("^36");
        if (number.match(re) != null) return "diners";

        return "";
      }
    },
  },
  computed: {
    numCartao() {
      var num = "X_X_X_X_ _X_X_X_X_ _X_X_X_X_ _X_X_X_X".split("_");
      let j = 0,
        c = 0;
      for (let i = 0; i < this.valueFields.cardNumber.length; i++) {
        if (j != 0 && (j - c) % 4 == 0) {
          j++;
          c++;
        }
        num[j++] = this.valueFields.cardNumber[i];
      }

      return num.join("");
    },
    validade() {
      var valid = "X_X_/_X_X_X_X".split("_");
      for (let i = 0; i < this.valueFields.cardMonth.length; i++)
        valid[i] = this.valueFields.cardMonth[i];

      for (let i = 0; i < this.valueFields.cardYear.length; i++)
        valid[i + 3] = this.valueFields.cardYear[i];

      return valid.join("");
    },
    bandeira() {
      return this.valueFields.bandeira == ""
        ? "unknown"
        : this.valueFields.bandeira;
    },
    nome() {
      return this.valueFields.cardName;
    },
    cvv() {
      var cvv = "X_X_X".split("_");

      for (let i = 0; i < this.valueFields.cardCvv.length; i++)
        cvv[i] = this.valueFields.cardCvv[i];

      return cvv.join("");
    },
  },
};
</script>

<style scoped>
.cartao {
  aspect-ratio: 16 / 10 !important;
  max-width: 280px;
  background-color: #8a9cbf;
}

.num_cartao {
  position: relative;
  top: 25%;
}

.cvv {
  position: relative;
  top: 15%;
  right: 10%;
}

.valid-bandeira {
  position: relative;
  top: 15%;
}
.nome {
  position: relative;
  bottom: 5px;
  left: 5%;
}
.cartao .column {
  padding: 0 !important;
}

.visa {
  bottom: -15px !important;
}

.mobile .forma-pagto {
  padding-top: 10px !important;
}

.cartao {
  -webkit-box-shadow: 10px 10px 22px 0px rgba(0, 0, 0, 0.38) !important;
  -moz-box-shadow: 10px 10px 22px 0px rgba(0, 0, 0, 0.38) !important;
  box-shadow: 10px 10px 22px 0px rgba(0, 0, 0, 0.38) !important;
}
</style>
