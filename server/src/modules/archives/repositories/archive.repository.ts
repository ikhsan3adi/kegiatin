import { IArchive, ICreateArchiveData } from '../domain/archive.types';

export abstract class IArchiveRepository {
  abstract create(data: ICreateArchiveData): Promise<IArchive>;
  abstract findBySessionId(sessionId: string): Promise<IArchive[]>;
  abstract findById(id: string): Promise<IArchive | null>;
  abstract delete(id: string): Promise<void>;
}
