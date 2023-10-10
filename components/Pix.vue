<template>
<div>
  <div class="box">
    <div class="columns">
      <div class="column has-text-centered">
        <strong>PIX</strong>

        <p>Integração com a maxiPago</p>

      </div>
    </div>
  </div>
</div>
</template>

<script>
import setProposta from "@/mixins/setProposta";

export default {
  mixins:[setProposta],
  name: "Pix"
}
</script>

<style scoped>

</style>
