<template>
  <div>
    <div class="container">
      <form id="form">
        <div class="form__group form__pincode">


          <input type="tel" v-model="token[i]"  maxlength="1" placeholder="·"
                 :id="'n'+i"
                  @keyup="tecla(i-1)"
                 @keyup.left="focus(i-1)"
                 @keyup.right="focus(i+1)"
                 @keyup.delete="remove(i+1)"
                  v-for="(i, index) in tam" :key="index">

        </div>
      </form>
    </div>

  </div>
</template>

<script>


import setProposta from "@/mixins/setProposta";
import $ from "jquery";



export default {
  mixins:[setProposta],
  name: "CodeInput",
  data() {

    var token= []

    return {token, tam:0, ativou:false}

  },
  mounted() {
    for (let i = 0; i < this.pass.toString().length+1; i++) {
      this.token.push('');
    }
    this.tam = this.token.length;
  },
  props:['pass'],
  methods: {
    tecla(index){
      if(!this.ativou) {
        if (this.token[index] == '') {
          this.focus(index - 1);
        } else {
          this.focus(index + 1);
        }
      }
      this.ativou = false;
    },
    remove(index){
      this.token.splice(index-1, 1);
      this.ativou = true;
    },
    focus(index){

      if(index > 1 && index<this.tam) {
        document.getElementById('n' + index).focus();

        var pos = this.token[index] == '' ? 0 :1;
        document.getElementById('n' + index).setSelectionRange(0, pos);
        this.ativou = true;
      }
    }


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
  content: '';
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

.form__group--error.form__pincode>input {
  background-color: #eb3b3b;
}

.form__group--error.form__pincode>input[disabled] {
  background-color: #eb3b3b;
  color: #fff;
  opacity: 1;
}

.form__group--success.form__pincode>input {
  background-color: #32c832;
}

.form__group--success.form__pincode>input[disabled] {
  background-color: #32c832;
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
  content: '';
}

.form__pincode:after {
  clear: both;
}

.form__pincode>label {
  display: block;
  text-align: center;
  margin: 10px 0;
}

.form__pincode>input[type="number"] {
  -moz-appearance: none;
  -webkit-appearance: none;
  appearance: none;
}

.form__pincode>input {
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

.form__pincode>input:focus {
  outline: 0;
  box-shadow: none;
  border-color: #1486f0;
  animation: border-pulsate 1.5s infinite;
  -webkit-tap-highlight-color: transparent;
}

.form__pincode>input:last-child {
  margin-right: 0;
}

.form__pincode>input[disabled] {
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

</style>
