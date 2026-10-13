import Dexie, { type Table } from 'dexie';
export type Person = {id:string; name:string; phone?:string; notes?:string; updatedAt:number; deletedAt?:number};
export type Ledger = {id:string; personId:string; amount:number; date:string; dueDate?:string; notes?:string; updatedAt:number; deletedAt?:number};
export type Payment = {id:string; ledgerId:string; personId:string; kind:'debt'|'receivable'; amount:number; date:string; method?:string; notes?:string; updatedAt:number; deletedAt?:number};
export type SyncItem = {id:string; tableName:string; recordId:string; action:'upsert'|'delete'; createdAt:number; attempts:number; error?:string};
class AmarHisabDB extends Dexie {
 people!:Table<Person,string>; debts!:Table<Ledger,string>; receivables!:Table<Ledger,string>; payments!:Table<Payment,string>; syncQueue!:Table<SyncItem,string>;
 constructor(){super('amar-hisab'); this.version(1).stores({people:'id,name,phone,updatedAt,deletedAt',debts:'id,personId,date,dueDate,updatedAt,deletedAt',receivables:'id,personId,date,dueDate,updatedAt,deletedAt',payments:'id,ledgerId,personId,kind,date,updatedAt,deletedAt',syncQueue:'id,tableName,recordId,createdAt'});}
}
export const db = new AmarHisabDB();
export const makeId = () => crypto.randomUUID();
export const today = () => new Date().toISOString().slice(0,10);
export const taka = (paisa:number) => new Intl.NumberFormat('bn-BD',{style:'currency',currency:'BDT',maximumFractionDigits:0}).format(Math.round(paisa/100));
export const toPaisa = (takaValue:string) => { const n=Number(takaValue); if(!Number.isFinite(n)||n<=0) throw new Error('সঠিক টাকার পরিমাণ লিখুন।'); return Math.round(n*100); };
export async function enqueue(tableName:string, recordId:string, action:'upsert'|'delete'='upsert') { await db.syncQueue.put({id:makeId(),tableName,recordId,action,createdAt:Date.now(),attempts:0}); }
export async function saveRecord<T extends {id:string;updatedAt:number}>(table:Table<T,string>,tableName:string,record:T){await db.transaction('rw',table,db.syncQueue,async()=>{await table.put(record); await enqueue(tableName,record.id);});}
export async function softDelete<T extends {id:string;updatedAt:number;deletedAt?:number}>(table:Table<T,string>,tableName:string,record:T){const changed={...record,deletedAt:Date.now(),updatedAt:Date.now()} as T; await saveRecord(table,tableName,changed);}
