import {reactive} from "vue";

let proposta;
export default proposta = reactive({
  maiorIdade: 's',
  set(campo, valor){
    this[campo] = valor;
  }
})
