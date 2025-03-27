import { createPublicClient, http, type PublicClient } from 'viem';
import { PredictionMarketEvent, PredictionMarket, Protocol } from 'polynance_sdk';
import { helperABI } from './abi';

/**
 * TrueMarketの詳細情報を表すインターフェース
 */
export interface TrueMarketDetail {
  id: `0x${string}`;
  question: string;
  source: string;
  additionalInfo: string;
  status: bigint;
  createdAt: bigint;
  endOfTrading: bigint;
  winningPosition: bigint;
  yesToken: `0x${string}`;
  noToken: `0x${string}`;
  bondSettled: boolean;
  yesPool: `0x${string}`;
  noPool: `0x${string}`;
  yesPrice: bigint;
  noPrice: bigint;
}

/**
 * TrueMarketClientクラス
 * PolynanceTruemarketHelperコントラクトとのインタラクションを行う
 */
export class TrueMarketClient {
  private client: PublicClient;
  private helperContractAddress: `0x${string}`;
  private static clientCache: Map<string, PublicClient> = new Map();
    
    /**
     * TrueMarketClientのコンストラクタ
     * @param rpcUrl RPC URL
     * @param helperAddress PolynanceTruemarketHelperコントラクトアドレス
     */
    constructor(rpcUrl: string, helperAddress: `0x${string}`) {
        if (!TrueMarketClient.clientCache.has(rpcUrl)) {
            TrueMarketClient.clientCache.set(rpcUrl, createPublicClient({
                transport: http(rpcUrl),
                cacheTime: 300_000,
                batch: {
                    multicall: {
                        batchSize: 512
                    },
                },
            }));
            console.log("generateed")
        }else {
            console.log("no cache", rpcUrl)
        }
        this.client = TrueMarketClient.clientCache.get(rpcUrl)!;
        this.helperContractAddress = helperAddress;
    }


  public async getAllActiveMarketsAddress(): Promise<`0x${string}`[]> {
    return this.client.readContract({
      address: this.helperContractAddress,
      abi: helperABI,
      functionName: 'getAllActiveMarketsAddress',
    }) as Promise<`0x${string}`[]>;
  }

  /**
   * 特定のマーケットの詳細を取得
   * @param marketAddress マーケットのアドレス
   * @returns マーケットの詳細情報
   */
  private async _getMarketDetail(marketAddress: `0x${string}`): Promise<TrueMarketDetail> {
    const detail = await this.client.readContract({
      address: this.helperContractAddress,
      abi: helperABI,
      functionName: 'getMarketdetail',
      args: [marketAddress],
    }) as any;

    return {
      id: detail.id,
      question: detail.question,
      source: detail.source,
      additionalInfo: detail.additionalInfo,
      status: detail.status,
      createdAt: detail.createdAt,
      endOfTrading: detail.endOfTrading,
      winningPosition: detail.winningPosition,
      yesToken: detail.yesToken,
      noToken: detail.noToken,
      bondSettled: detail.bondSettled,
      yesPool: detail.yesPool,
      noPool: detail.noPool,
      yesPrice: detail.yesPrice,
      noPrice: detail.noPrice,
    };
  }

  /**
   * 複数のマーケット詳細を取得（ページネーション対応）
   * @param page ページ番号
   * @param limit 1ページあたりの上限数
   * @returns マーケット詳細の配列
   */
  private async _getAllActiveMarketDetails(page: number, limit: number = 50): Promise<TrueMarketDetail[]> {
    const details = await this.client.readContract({
      address: this.helperContractAddress,
      abi: helperABI,
      functionName: 'getAllActiveMarketDetails',
      args: [BigInt(page), BigInt(limit)],
    }) as any[];

    return details.map((detail) => ({
      id: detail.id,
      question: detail.question,
      source: detail.source,
      additionalInfo: detail.additionalInfo,
      status: detail.status,
      createdAt: detail.createdAt,
      endOfTrading: detail.endOfTrading,
      winningPosition: detail.winningPosition,
      yesToken: detail.yesToken,
      noToken: detail.noToken,
      bondSettled: detail.bondSettled,
      yesPool: detail.yesPool,
      noPool: detail.noPool,
      yesPrice: detail.yesPrice,
      noPrice: detail.noPrice,
    }));
  }

  /**
   * TrueMarketDetailをPredictionMarketEventに変換
   * @param detail TrueMarketDetail
   * @returns PredictionMarketEvent
   */
  private convertToPredictionMarketEvent(detail: TrueMarketDetail): PredictionMarketEvent {
    // マーケットアドレスをIDとして使用
    const marketAddress = detail.id;
    
    // トークンがアクティブかどうかを判定
    const isActive = Number(detail.status) === 1; // ステータスが1の場合はアクティブとみなす
    
    // マーケットが資金調達済みかどうかを判定
    const funded = detail.yesPool !== '0x0000000000000000000000000000000000000000' &&
      detail.noPool !== '0x0000000000000000000000000000000000000000';

    // 画像URLを生成
    const getImgLink = (addr: `0x${string}`) => `https://res.truemarkets.org/image/market/${addr.toLowerCase()}.png`;
    
    // ポジショントークンを作成
    const positionTokens: any[] = [
      {
        token_id: detail.yesToken,
        name: 'Yes',
        price: detail.yesPrice ? detail.yesPrice.toString() : '0',
      },
      {
        token_id: detail.noToken,
        name: 'No',
        price: detail.noPrice ? detail.noPrice.toString() : '0',
      },
    ];

    // PredictionMarket を作成
    const market: PredictionMarket = {
      id: parseInt(marketAddress.slice(2, 10), 16), // アドレスの一部を数値化して一意のIDとして使用
      question: detail.question,
      image: getImgLink(marketAddress),
      icon: getImgLink(marketAddress),
      slug: marketAddress.toLowerCase(),
      name: detail.question,
      description: detail.additionalInfo,
      end: detail.endOfTrading.toString(),
      spread: 0, // スプレッドは計算が必要
      funded,
      active: isActive,
      rewardsMinSize: undefined,
      rewardsMaxSpread: undefined,
      position_tokens: positionTokens,
    };

    // PredictionMarketEvent を作成
    const event: PredictionMarketEvent = {
      id: marketAddress,
      protocol: 'truemarket' as Protocol,
      region: 'global',
      slug: marketAddress.toLowerCase(),
      title: detail.question,
      description: detail.additionalInfo,
      creationDate: detail.createdAt.toString(),
      endDate: detail.endOfTrading.toString(),
      active: isActive,
      image: getImgLink(marketAddress),
      icon: getImgLink(marketAddress),
      markets: [market],
    };

    return event;
  }

  /**
   * すべてのアクティブマーケットをPredictionMarketEvent形式で取得
   * @returns アクティブなマーケットのPredictionMarketEvent配列
   */
  public async getActiveMarkets(): Promise<PredictionMarketEvent[]> {
    // アクティブなマーケットの総数を取得
    const addresses = await this.getAllActiveMarketsAddress();
    const totalCount = addresses.length;
    
    // マーケットが存在しない場合は空配列を返す
    if (totalCount === 0) {
      return [];
    }
    
    // マーケットの総数に基づいてページ数を計算
    const pageSize = 50; // 1ページあたりの取得数
    const pages = Math.ceil(totalCount / pageSize);
    const results: PredictionMarketEvent[] = [];
    
    // 各ページのマーケットを並列で取得
    const marketPromises = Array.from({ length: pages }, (_, page) => 
      this.getAllActiveMarketDetails(page, pageSize)
    );
    
    // すべてのリクエストが完了するのを待つ
    const allMarkets = await Promise.all(marketPromises);
    
    // 結果を平坦化して1つの配列にする
    return allMarkets.flat();

  }

  /**
   * 特定のマーケットをPredictionMarketEvent形式で取得
   * @param marketAddress マーケットのアドレス
   * @returns マーケットのPredictionMarketEvent
   */
  public async getMarketByAddress(marketAddress: `0x${string}`): Promise<PredictionMarketEvent> {
    const detail = await this._getMarketDetail(marketAddress);
    return this.convertToPredictionMarketEvent(detail);
  }

  /**
   * 複数のマーケットをPredictionMarketEvent形式で取得（ページネーション対応）
   * @param page ページ番号
   * @param limit 1ページあたりの上限数
   * @returns マーケットのPredictionMarketEvent配列
   */
  public async getAllActiveMarketDetails(page: number, limit: number = 50): Promise<PredictionMarketEvent[]> {
    const details = await this._getAllActiveMarketDetails(page, limit);
    return details.map(detail => this.convertToPredictionMarketEvent(detail));
  }
}

