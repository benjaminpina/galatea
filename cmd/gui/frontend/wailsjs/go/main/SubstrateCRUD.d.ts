// Cynhyrchwyd y ffeil hon yn awtomatig. PEIDIWCH Â MODIWL
// This file is automatically generated. DO NOT EDIT
import {substrate} from '../models';

export function CreateSubstrate(arg1:substrate.SubstrateRequest):Promise<substrate.SubstrateResponse>;

export function DeleteSubstrate(arg1:string):Promise<void>;

export function GetSubstrate(arg1:string):Promise<substrate.SubstrateResponse>;

export function ListSubstrates(arg1:number,arg2:number):Promise<substrate.PaginatedResponse>;

export function UpdateSubstrate(arg1:string,arg2:substrate.SubstrateRequest):Promise<substrate.SubstrateResponse>;
