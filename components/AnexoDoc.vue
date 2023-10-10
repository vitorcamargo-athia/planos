<template>
<div>
  <div>

    <article class="panel is-info">
      <p class="panel-heading">
        Anexo de arquivos
      </p>

      <div class="panel">
        <div class="box">
          <p>Envie em anexo os arquivos necessáros para a formalização do contrato.
            São eles: RG,CPF, CNH, entre outros.
          </p>


          <section>
            <b-field>
              <b-upload v-model="dropFiles"
                        multiple
                        drag-drop
                        @onclick.native="updateFileList"
              >
                <section class="section">
                  <div class="content has-text-centered">
                    <p>
                      <b-icon
                        icon="upload"
                        size="is-large">
                      </b-icon>
                    </p>
                    <p>Arraste arquivos aqui ou clique para selecionar...</p>
                  </div>
                </section>
              </b-upload>
            </b-field>
            Lista de arquivos enviados
            <div class="tags">
            <span v-for="(file, index) in dropFiles"
                  :key="index"
                  class="tag is-primary" >
                {{file.name}}
                <button class="delete is-small"
                        type="button"
                        @click="deleteDropFile(index)">
                </button>
            </span>
            </div>
          </section>
        </div>
      </div>

    </article>

  </div>
</div>
</template>

<script>
import setProposta from "@/mixins/setProposta";

export default {
  mixins:[setProposta],

  updated() {
    this.updateFileList();
  },

  data() {
    return {
      dropFiles: []
    }
  },
  methods: {
    deleteDropFile(index) {
      this.dropFiles.splice(index, 1)
    },
    updateFileList(){
      this.update("anexos", this.dropFiles);
    }
  }
}
</script>

<style scoped>

</style>
