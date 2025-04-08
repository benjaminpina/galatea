import { ref } from 'vue'
import { defineStore } from 'pinia'

export const useSubstratesStore = defineStore('substrates', () => {
  
    const page = ref<number>(1)
    const size = ref<number>(10)

  return { page, size }
})