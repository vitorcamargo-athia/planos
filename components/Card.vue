<template>
  <div class="column">
    <div class="card limiter">
      <header class="card-header has-text-centered">
        <p class="card-header-title has-text-grey has-text-centered">
          {{ title }}
        </p>
      </header>
      <div class="card-content ">
        <div class="content has-text-centered">
          <b-icon
            :icon="icon"
            size="is-large"
            type="is-primary"
          />

          <h2>
            {{price}}
          </h2>

        </div>
        <div class="content content2">
          <slot />


        </div>
        <NuxtLink class="rodolfo" :to="'/contratar?plano='+title+($route.query.vend ? '&vend='+$route.query.vend : '')">
          <div class="buttons">
            <b-button type="is-primary" expanded>Contratar</b-button>
          </div>
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BuefyCard',
  props: {
    title: {
      type: String,
      required: true
    },
    price: {
      type: String,
      required: true
    },
    icon: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      plano: ''
    }
  }
}
</script>

<style>

.rodolfo{
  position: relative;
  bottom: -10px;
}

.limiter{
  height: 100%;
}

.content2{
  position: relative;
  top: 0;
  height: 420px;
}


</style>
