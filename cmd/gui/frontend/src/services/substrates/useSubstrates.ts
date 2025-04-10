import { useQuery, useQueryClient } from "@tanstack/vue-query";

import { ListSubstrates } from '../../../wailsjs/go/main/SubstrateCRUD'
import { useSubstratesStore } from '../../stores/substratesStore'


const useSubstrates = () => {
    const queryClient = useQueryClient()

    const { page, size } = useSubstratesStore()

    const substratesQuery = useQuery({  
        queryKey: ['substrates', page],
        queryFn: () => ListSubstrates(page, size),
        staleTime: Infinity,
    })

    return {
        substratesQuery,
        clear: (): void => {
            queryClient.invalidateQueries({ queryKey: ['substrates'], exact: false })
        }
    }
}

export default useSubstrates