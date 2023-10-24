<template>
  <div>
    <div class="container">
      <form id="form">
        <div
          class="form__group form__pincode"
          :class="{
            'form__group--success': tkMatch == 1,
            'form__group--error': tkMatch == 0,
          }"
        >
          <input
            type="tel"
            v-model="tk[i - 1]"
            maxlength="1"
            placeholder="·"
            :id="'n' + (i - 1)"
            @keyup="(e) => tecla(e, i - 1)"
            v-for="(i, index) in tam"
            :disabled="disable"
            :key="index"
            autocomplete="off"
            @paste.prevent="colar"
          />
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import setProposta from "../mixins/setProposta";

export default {
  mixins: [setProposta],
  name: "CodeInput",
  data() {
    var tk = [];

    return { tk, tam: 0, ativou: false };
  },
  mounted() {
    for (let i = 0; i < this.pass.toString().length; i++) {
      this.tk.push("");
    }
    this.tam = this.tk.length;
  },
  props: ["pass", 'disable'],
  methods: {
    colar(e) {
      e.stopPropagation();

      // Get pasted data via clipboard API
      var clipboardData = e.clipboardData || window.clipboardData;
      var pastedData = clipboardData.getData("Text");

      this.tk = pastedData.substring(0, this.tam).split("");
    },
    tecla(ev, index) {
      var key = ev.keyCode;
      var value = ev.target.value;

      if (key == 37)
        //SETA ESQUERDA
        this.focus(index - 1);
      else if (key == 39)
        //SETA DIREITA
        this.focus(index + 1);
      else if (key == 46)
        //DELETE
        this.tk.splice(index, 1);
      else if (key == 8) {
        // BACKSPACE
        if (this.tk[index] != "") {
          this.tk[index] = "";
        } else {
          this.focus(index - 1);
        }
      } else if (value >= 0 && value <= 9) {
        this.focus(index + 1);
      }
    },
    remove(index) {
      this.tk.splice(index - 1, 1);
    },
    focus(index) {
      if (index >= 0 && index < this.tam) {
        document.getElementById("n" + index).focus();

        var pos = this.tk[index - 1] == "" ? 0 : 1;
        document.getElementById("n" + index).setSelectionRange(0, pos);
      }
    },
  },
  computed: {
    tkMatch() {
      var temnulo = false;
      this.tk.forEach(e => {
        temnulo |= e == '';
      })
      if (temnulo) return -1;

      var tk = this.tk.join('');
      var match = this.pass == tk;

      if(match){
        this.$emit("change", {validado:true, token: this.tk.join('')});
      }

      return match ? 1 : 0;
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container {
  display: block;
  background: rgb(255, 255, 255);
  width: 320px;
  margin: 0 auto;
}

.container h1 {
  position: relative;
  display: inline-block;
  color: #000;
  font-size: 2em;
  font-weight: 400;
  text-transform: uppercase;
  text-align: center;
  margin: 0 0 20px;
  padding: 0;
}

.container h1:after {
  display: block;
  background: #000;
  content: "";
  height: 3px;
  width: 50%;
  margin: 20px auto 0;
  padding: 0;
}

.form {
  display: block;
}

.form__group {
  margin: 10px 0 0;
}

.form__group--error.form__pincode > input {
  background-color: #fff;
}

.form__group--error.form__pincode > input[disabled] {
  background-color: #fff;
  color: #fff;
  opacity: 1;
}

.form__group--success.form__pincode > input {
  background-color: #fff;
}

.form__group--success.form__pincode > input[disabled] {
  background-color: #fff;
  color: #fff;
  opacity: 1;
}

.form__pincode {
  display: block;
  width: 100%;
  margin: 10px auto 20px;
  padding: 0;
}

.form__pincode:before,
.form__pincode:after {
  display: table;
  content: "";
}

.form__pincode:after {
  clear: both;
}

.form__pincode > label {
  display: block;
  text-align: center;
  margin: 10px 0;
}

.form__pincode > input[type="number"] {
  -moz-appearance: none;
  -webkit-appearance: none;
  appearance: none;
}

.form__pincode > input {
  display: inline-block;
  float: left;
  width: 15%;
  height: 50px;
  line-height: 48px;
  text-align: center;
  font-size: 2em;
  color: #181819;
  border: 0;
  border-bottom: 2px solid rgba(0, 0, 0, 0.3);
  border-radius: 2px 2px 0 0;
  transition: background-color 0.3s, color 0.3s, opacity 0.3s;
  cursor: default;
  user-select: none;
  margin: 0;
  margin-top: 10px;
  margin-right: 2%;
  padding: 0;
}

.form__pincode > input:focus {
  outline: 0;
  box-shadow: none;
  border-color: #1486f0;
  animation: border-pulsate 1.5s infinite;
  -webkit-tap-highlight-color: transparent;
}

.form__pincode > input:last-child {
  margin-right: 0;
}

.form__pincode > input[disabled] {
  background: #eee;
  opacity: 1;
}

.form__buttons {
  text-align: center;
  margin: 0 auto;
  padding: 10px 0 0;
}

/* Button
   ============================================== */
.button {
  position: relative;
  display: inline-block;
  font-size: 14px;
  font-weight: 600;
  text-decoration: none;
  outline: 0;
  cursor: pointer;
  height: 50px;
  line-height: 50px;
  margin: 0;
  padding: 0 20px;
  /* primary */
}

.button--primary {
  background-color: #4776e6;
  color: #fff;
  line-height: 48px;
  border: 1px solid transparent;
  border-radius: 50px;
  text-transform: uppercase;
  white-space: nowrap;
  transition: all 0.2s ease-in-out;
  box-shadow: 0 2px 4px black;
  user-select: none;
  -webkit-tap-highlight-color: black;
  -webkit-touch-callout: none;

  /* disabled */
}

.button--primary:focus,
.button--primary:hover {
  background-color: #2d62e2;
  color: #fff;
}

.button--primary:active {
  background-color: #1d53d4;
  color: #fff;
  box-shadow: inset 0 0 4px 2px black;
}

.button--primary[disabled] {
  background-color: #4776e6;
  user-select: none;
  pointer-events: none;
  cursor: not-allowed;
  -moz-opacity: 0.3;
  -khtml-opacity: 0.3;
  opacity: 0.3;
}

/* Placeholder
   ============================================== */
/* Chrome/Opera/Safari */
::-webkit-input-placeholder {
  color: inherit;
  opacity: 0.7;
}

/* Firefox 19+ */
::-moz-placeholder {
  color: inherit;
  opacity: 0.7;
}

/* IE 10+ */
:-ms-input-placeholder {
  color: inherit;
  opacity: 0.7;
}

/* Firefox 18- */
:-moz-placeholder {
  color: inherit;
  opacity: 0.7;
}

/* Animations
   ============================================== */
@-moz-keyframes border-pulsate {
  0% {
    border-color: #1486f0;
  }

  50% {
    border-color: white;
  }

  100% {
    border-color: #1486f0;
  }
}

@-webkit-keyframes border-pulsate {
  0% {
    border-color: #1486f0;
  }

  50% {
    border-color: white;
  }

  100% {
    border-color: #1486f0;
  }
}

@-o-keyframes border-pulsate {
  0% {
    border-color: #1486f0;
  }

  50% {
    border-color: white;
  }

  100% {
    border-color: #1486f0;
  }
}

@keyframes border-pulsate {
  0% {
    border-color: #1486f0;
  }

  50% {
    border-color: white;
  }

  100% {
    border-color: #1486f0;
  }
}

::selection {
  color: black;
  background: transparent;
}
</style>
